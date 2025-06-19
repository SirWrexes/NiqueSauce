{
  config,
  pkgs,
  lib,
  ...
}:

let
  lazylib = import ./lib { inherit lib; };

  inherit (lib.attrsets) attrNames;

  cfg = config.programs.neovim.lazy-nvim.lspconfig;
in
{
  options.programs.neovim.lazy-nvim.lspconfig =
    let
      inherit (lib.lists) head;
      inherit (lazylib) types;
      inherit (lazylib.modules) toModule;
      inherit (lazylib.options) mkOption;
      inherit (lazylib.types) isLuaInline;
      inherit (lazylib.submodules) LazySpec;

      applyToDefaults =
        name: source:
        if source == null then
          null
        else if isLuaInline source then
          source // { _isModule = false; }
        else
          rec {
            _isModule = true;
            module = toModule "lspconfig/defaults" { inherit source name; };
            requirePath = head (attrNames module);
          };
    in
    {
      defaultCapabilities =
        with types;
        mkOption {
          type = nullOr luaSnippet;
          default = null;
          apply = applyToDefaults "capabilities";
          description = ''
            Honestly, I don't really know what those are, but I know they're often necessary to make
            completion plugins work properly.
            Check the documentation for your completion plugin, there's probably a section about those.
          '';
        };

      defaultOnAttach =
        with types;
        mkOption {
          type = nullOr (listOf luaSnippet);
          default = [ ];
          apply = map (applyToDefaults "on_attach");
          description = ''
            List of all the hooks that are called by default on attaching the LSP to a buffer.
            They will be wrapped in a fonction called `on_attach` that will be passed to handlers.
            In general, you want to use this for hooks that you'll use on *ALL* filetypes.
          '';
        };

      servers =
        with types;
        mkOption {
          type = nullOr (attrsOf LazySpec);
          default = { };
          description = ''
            Lazy-like configurations for your LSPs.
            It will be turned into a lazy spec with a few key differences:
              - lspconfig will be added to your spec's dependencies.
              - If you define a `config` function, it will be wrapped in a factory function exposing a `get_defaults` function.
                This `get_defaults` will return a table containing two entries that you can use in your setup if you wish:
                - on_attach: The default hook, that you can define with `lspconfig.defaultOnAttach`.
                - capabilities: The default capabilities set that you can define with `lspconfig.defaultCapabilities`.
              - If you haven't defined one, it will automatically be set to `function(_, opts) require("lspconfig").<SERVER>.setup(opts) end`.
                `opts` will be extended with default `capabilities` and `on_attach`.
                If you do not want that, you can set them to `false` in your spec's `opts`.
          '';
        };
    };

  config =
    let
      inherit (lib.attrsets)
        attrValues
        mapAttrs
        mergeAttrsList
        updateManyAttrsByPath
        ;
      inherit (lib.generators) mkLuaInline;
      inherit (lib.lists) filter length;
      inherit (lib.strings) concatStringsSep;
      inherit (lib.trivial) pipe;

      inherit (lazylib) toLua;
      inherit (lazylib.attrsets) stripNulls;
      inherit (lazylib.types) isLuaInline;

      modules =
        with cfg;
        (pipe defaultOnAttach [
          (filter (hook: hook._isModule))
          (map ({ module, ... }: module))
        ])
        ++ (
          if defaultCapabilities != null && defaultCapabilities._isModule then
            [ defaultCapabilities.module ]
          else
            [ ]
        );

      callOnAttachHook =
        hook:
        if hook._isModule then
          ''require(${toLua hook.requirePath})(client, buffer)''
        else
          ''(${hook.expr})(client, buffer)'';

      defaults =
        with cfg;
        stripNulls {
          capabilities =
            if defaultCapabilities != null && defaultCapabilities._isModule then
              mkLuaInline ''require(${toLua defaultCapabilities.requirePath})''
            else
              defaultCapabilities;
          on_attach = mkLuaInline ''
            function(client, buffer)
              ${pipe defaultOnAttach [
                (map callOnAttachHook)
                (concatStringsSep "\n")
              ]}
            end
          '';
        };

      setConfig =
        server: config:
        if config == null then
          mkLuaInline ''
            function(_, opts)
              if opts.on_attach == nil then
                opts.on_attach = ${defaults.on_attach.expr}
              elseif opts.on_attach == false then
                opts.on_attach = nil
              end

              if opts.capabilities == nil then
                opts.capabilities = ${defaults.capabilities.expr}
              elseif opts.capabilities == false then
                opts.capabilities = nil
              end

              require("lspconfig").${server}.setup(opts)
            end
          ''
        else if isLuaInline config then
          mkLuaInline ''
            (function(get_defaults)
              return ${config.expr}
            end)(function()
              return ${toLua defaults}
            end)
          ''
        else
          throw ''Lua file `config` is not supported.'';

      setDefaults =
        server: spec:
        updateManyAttrsByPath [
          {
            path = [ "config" ];
            update = setConfig server;
          }
          {
            path = [ "dependencies" ];
            update = deps: deps ++ [ { package = pkgs.vimPlugins.nvim-lspconfig; } ];
          }
        ] spec;

      servers = mapAttrs setDefaults cfg.servers;
    in
    lib.mkIf (config.programs.neovim.lazy-nvim.enable && (length (attrNames cfg.servers) > 0)) {
      home.file = mergeAttrsList modules;
      programs.neovim.lazy-nvim.plugins = attrValues servers;
    };
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  lazylib = import ./lib { inherit lib; };

  inherit (lib.attrsets) attrNames;
  inherit (lazylib.attrsets) stripNulls;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.trivial) flip pipe;

  inherit (lazylib) toLua;

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
      inherit (lazylib.submodules) LazyKey LspConfig;

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
            See `:h vim.lsp.ClientConfig`, field `{capabilities}`.
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

      filetypes =
        with types;
        mkOption {
          type = nullOr (listOf str);
          default = [ ];
          description = ''
            Extra filetypes to load `lspconfig` for without necessarilly setting a server config for them.
          '';
        };

      keys =
        with types;
        mkOption {
          type = nullOr (listOf LazyKey);
          default = [ ];
        };

      servers =
        with types;
        mkOption {
          type = nullOr (attrsOf LspConfig);
          default = { };
          description = ''
            See `:h vim.lsp.Config` and `:h vim.lsp.ClientConfig`.
            Not everything is implemented. I'll add stuff if and when necessary—feel free to file an issue and/or PR.
          '';
          example =
            literalExpression
              # nix
              ''
                let
                  ls = "lua-language-server";
                in
                {
                  home.packages = [ pkgs.${ls} ];

                  programs.neovim.lazy-nvim.lspconfig.servers.luals = {
                    cmd = ls;
                    filetypes = [ "lua" ];
                    root_markers = [ [ ".luarc.json" ".luarc.jsonc" ] ".git" ];
                    settings.Lua = {
                      hint.enable = true;
                      completion.callSnippet = "Replace";
                    };
                  };
                }
              '';
        };

      luaDefaults =
        let
          callOnAttachHook =
            hook:
            if hook._isModule then
              ''require(${toLua hook.requirePath})(client, buffer)''
            else
              ''(${hook.expr})(client, buffer)'';
        in
        with types;
        mkOption {
          type = submodule {
            options = {
              on_attach = mkOption { type = luaSnippet; };
              capabilities = mkOption { type = luaSnippet; };
              root_markers = mkOption { type = listOf (either str (listOf str)); };
            };
          };
          readOnly = true;
          default =
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
              root_markers = [ ".git" ];
            };
        };
    };

  config =
    let
      inherit (lib.attrsets) attrValues mapAttrs mergeAttrsList;
      inherit (lib.lists) concatMap filter length;

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

      cleanupConfig = flip pipe [
        (flip removeAttrs [ "enable" ])
        stripNulls
      ];

      toLuaConfig =
        name:
        { enable, ... }@config:
        ''
          vim.lsp.config(${toLua name}, ${toLua (cleanupConfig config)})
          ${if enable then "vim.lsp.enable(${toLua name})" else "-- Auto attach disabled"}
        '';

      toLuaConfig' = flip pipe [
        (mapAttrs toLuaConfig)
        attrValues
        (concatStringsSep "\n")
      ];
    in
    lib.mkIf (config.programs.neovim.lazy-nvim.enable && (length (attrNames cfg.servers) > 0)) {
      home.file = mergeAttrsList modules;
      programs.neovim.lazy-nvim.plugins = [
        {
          package = pkgs.vimPlugins.nvim-lspconfig;

          priority = 999;

          ft =
            cfg.filetypes
            ++ (concatMap (
              {
                filetypes ? [ ],
                ...
              }:
              filetypes
            ) (attrValues cfg.servers));

          config =
            mkLuaInline
              # lua
              ''
                function()
                  vim.lsp.config('*', ${toLua cfg.luaDefaults})
                  ${toLuaConfig' cfg.servers}
                end
              '';

          inherit (cfg) keys;
        }
      ];
    };
}

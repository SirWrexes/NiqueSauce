{
  config,
  pkgs,
  lib,
  ...
}:

let
  lazylib = import ./lib { inherit lib; };

  inherit (builtins) groupBy typeOf;

  inherit (lib.attrsets)
    attrNames
    attrValues
    attrsToList
    mapAttrs
    mergeAttrsList
    updateManyAttrsByPath
    ;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) filter head unique;
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) concatStringsSep;
  inherit (lib.trivial) pipe;

  inherit (lazylib) toLua;
  inherit (lazylib.attrsets) stripNulls;
  inherit (lazylib.modules) toModule;
  inherit (lazylib.types) isLuaInline;

  lazy = config.programs.neovim.lazy-nvim;
  cfg = lazy.mason;
in
{
  options.programs.neovim.lazy-nvim.mason =
    let
      inherit (lazylib) types;
      inherit (lazylib.options) mkOption;
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
            module = toModule "mason/defaults" { inherit source name; };
            requirePath = head (attrNames module);
          };

      applyToHandlers =
        handlers:
        let
          pairs = attrsToList handlers;

          groups =
            {
              inline = [ ];
              module = [ ];
              set = [ ];
            }
            // (groupBy (
              { value, ... }:
              if isLuaInline value then
                "inline"
              else if typeOf value == "path" then
                "module"
              else
                "set"
            ) pairs);
        in
        updateManyAttrsByPath [
          {
            path = [ "set" ];
            update =
              sets:
              mergeAttrsList (
                map (
                  { name, value }:
                  {
                    ${name} = value;
                  }
                ) sets
              );
          }
          {
            path = [ "inline" ];
            update =
              inlines:
              mergeAttrsList (
                map (
                  { name, value }:
                  {
                    ${name} = value;
                  }
                ) inlines
              );
          }
          {
            path = [ "module" ];
            update =
              modules:
              mergeAttrsList (
                map (
                  { name, value }:
                  {
                    ${name} = rec {
                      module = toModule "mason/handlers" value;
                      requirePath = head (attrNames module);
                    };
                  }
                ) modules
              );
          }
        ] groups;
    in
    {
      enable = mkEnableOption "Mason LSP manager with none-ls";

      extraDependencies =
        with types;
        mkOption {
          type = nullOr (listOf LazySpec);
          default = [ ];
        };

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

      ensureInstalled =
        with types;
        mkOption {
          type = nullOr (listOf str);
          default = [ ];
          description = ''
            List of LSPs to install. Make sure you only provide actua `lspconfig`-compatible sources here.
            If you want to install a linter, formatter, or something else like that not normally supprted
            by `lspconfig', use `programs.neovim.lazy-nvim.mason.ensureNoneLsInstalled` instead.
          '';
        };

      ensureNoneLsInstalled =
        with types;
        mkOption {
          type = nullOr (listOf str);
          default = [ ];
          description = ''
            List of plugins that will be managed by Mason *through `none-ls`.
            This includes linters, formatters, etc.
          '';
        };

      handlers =
        with types;
        mkOption {
          type = nullOr (attrsOf (either attrs luaSnippet)); # TODO: Disable merging for each LSP
          default = { };
          description = ''
            Configuration for your LSPs.

            If you're using only a set, then the default `on_attach` will be used.
            It will call all of the functions you've defined in `programs.neovim.lazy-nvim.mason.defaultOnAttach`
            with the client and current buffer as parameters.
            Also don't forget that, when using a set, if you still wish to define an `on_attach` hook, you must
            use snake_case instead of camelCase, otherwise it will be ignored.

            If using lua, either path to a file or inline, it must be a function of the following signature:
            ```
              fun(lspconfig: LspConfigMain, defaults: MasonDefaults): function
            ```
            - LspConfigMain -> `require("lspconfig")`
            - MasonDefaults -> `{ on_attach: fun(client: vim.lsp.Client, buffer: number), capabilities: Capabilities }`
          '';
          apply = applyToHandlers;
        };
    };

  config =
    let
      event = [
        "BufReadPre"
        "BufNewFile"
      ];

      modules =
        with cfg;
        (attrValues (mapAttrs (ls: { module, ... }: module) cfg.handlers.module))
        ++ (
          if defaultCapabilities != null && defaultCapabilities._isModule then
            [ defaultCapabilities.module ]
          else
            [ ]
        )
        ++ (pipe defaultOnAttach [
          (filter (hook: hook._isModule))
          (map ({ module, ... }: module))
        ]);

      callOnAttachHook =
        hook:
        if hook._isModule then
          mkLuaInline ''
            require(${toLua hook.requirePath})(client, buffer)
          ''
        else
          mkLuaInline ''
            (${hook.expr})(client, buffer)
          '';

      masonDefaults =
        with cfg;
        pipe
          {
            capabilities =
              if defaultCapabilities != null && defaultCapabilities._isModule then
                mkLuaInline ''require(${toLua default.requirePath})''
              else
                defaultCapabilities;
            on_attach = mkLuaInline ''
              function(client, buffer)
                ${pipe defaultOnAttach [
                  (map callOnAttachHook)
                  (map ({ expr, ... }: expr))
                  (concatStringsSep "\n")
                ]}
              end
            '';
          }
          [
            stripNulls
            toLua
          ];

      handlers =
        let
          prepared = updateManyAttrsByPath [
            {
              path = [ "set" ];
              update = mapAttrs (
                ls: opts:
                mkLuaInline ''
                  function() require("lspconfig")[${toLua ls}].setup(${toLua opts}) end
                ''
              );
            }
            {
              path = [ "inline" ];
              update = mapAttrs (
                ls: lambda:
                mkLuaInline ''
                  function() (${lambda})(require("lspconfig"), ${masonDefaults}) end
                ''
              );
            }
            {
              path = [ "module" ];
              update = mapAttrs (
                ls:
                { requirePath, ... }:
                mkLuaInline ''
                  function() require(${toLua requirePath})(require("lspconfig"), ${masonDefaults}) end
                ''
              );
            }
          ] cfg.handlers;
        in
        prepared.set // prepared.inline // prepared.module;

      handlersWithDefault = mkLuaInline ''
        (function()
          local handlers = ${toLua handlers}
          handlers[1] = function(lang)
            require("lspconfig")[lang].setup(${masonDefaults})
          end
          return handlers
        end)()
      '';
    in
    lib.mkIf (cfg.enable && lazy.enable) {
      home.file = mergeAttrsList modules;

      programs.neovim.lazy-nvim.plugins =
        with pkgs.vimPlugins;
        map (plugin: plugin // { inherit event; }) [
          {
            package = mason-lspconfig-nvim;

            priority = 0; # Lowest priority, loads last

            dependencies = [
              { package = nvim-lspconfig; }
              {
                package = mason-nvim;
                config = true;
              }
            ] ++ cfg.extraDependencies;

            opts = {
              ensure_installed = unique (cfg.ensureInstalled ++ (attrNames handlers));
              handlers = handlersWithDefault;
              automatic_enable = true;
            };
          }

          {
            package = mason-null-ls-nvim;

            priority = 1; # Middle priority, loads second

            dependencies = [ { package = mason-lspconfig-nvim; } ];

            opts = {
              handlers =
                mkLuaInline
                  # lua
                  ''
                    {
                      function(source, methods)
                        require("mason-null-ls").default_setup(source, methods)
                        end
                    }
                  '';
              ensure_installed = cfg.ensureNoneLsInstalled;
            };
          }

          {
            package = none-ls-nvim;

            priority = 2; # Highest priority, loads first

            dependencies = [
              { package = plenary-nvim; }
              { package = mason-null-ls-nvim; }
            ];

            config = true;
          }
        ];
    };
}

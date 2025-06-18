{
  config,
  pkgs,
  lib,
  ...
}:

let
  lazylib = import ./lib { inherit lib; };

  inherit (builtins) typeOf groupBy;
  inherit (lib.attrsets)
    attrNames
    attrValues
    attrsToList
    mapAttrs
    mergeAttrsList
    updateManyAttrsByPath
    ;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) head unique;
  inherit (lib.options) mkEnableOption;
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
              { name, value }:
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

      defaultCapabilities =
        with types;
        mkOption {
          type = nullOr luaSnippet;
          default = null;
          apply = applyToDefaults "capabilities";
        };

      defaultOnAttach =
        with types;
        mkOption {
          type = nullOr luaSnippet;
          default = null;
          apply = applyToDefaults "on_attach";
        };

      ensureInstalled =
        with types;
        mkOption {
          type = nullOr (listOf str);
          default = [ ];
        };

      handlers =
        with types;
        mkOption {
          type = nullOr (attrsOf (either attrs luaSnippet)); # TODO: Disable merging for each LSP
          default = { };
          description = ''
             If using a set, remember to use `on_attach` and not `onAttach`. Lua prefers snake_case.
             If using lua, either path to a file or inline, it must be a function of the following signature:
            ```
              fun(lspconfig: LspConfigMain, defaults: MasonDefaults): function
            ```
            - LspConfigMain -> `require("lspconfig")`
            - MasonDefaults -> `{ on_attach: fun(client: vim.lsp.Client, buffer: number), capabilities: Capabilities }`
            The returned function will be called on detecting the filetype the handler is set for.
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

      getDefaultAsModuleList =
        default: if default != null && default._isModule then [ default.module ] else [ ];

      modules =
        (attrValues (mapAttrs (ls: { module, ... }: module) cfg.handlers.module))
        ++ (getDefaultAsModuleList cfg.defaultOnAttach)
        ++ (getDefaultAsModuleList cfg.defaultCapabilities);

      getDefaultAsLua =
        default:
        if default != null && default._isModule then
          mkLuaInline ''require(${toLua default.requirePath}) ''
        else
          default;

      luaDefaults = toLua (stripNulls {
        capabilities = getDefaultAsLua cfg.defaultCapabilities;
        on_attach = getDefaultAsLua cfg.defaultOnAttach;
      });

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
                  function() (${lambda})(require("lspconfig"), ${luaDefaults}) end
                ''
              );
            }
            {
              path = [ "module" ];
              update = mapAttrs (
                ls:
                { requirePath, ... }:
                mkLuaInline ''
                  function() require(${toLua requirePath})(require("lspconfig"), ${luaDefaults}) end
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
            require("lspconfig")[lang].setup(${luaDefaults})
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
            ]; # ++ cfg.dependencies; # TODO: Add support for extra dependencies

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

            opts.handlers = mkLuaInline ''
              {
                function(source, methods)
                  require("mason-null-ls").default_setup(source, methods)
                end
              }
            '';
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

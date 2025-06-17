{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.trivial) pipe;
  inherit (lib.strings) readFile removeSuffix;
  inherit (lib.generators) mkLuaInline;
  inherit (config.programs.neovim.lazy-nvim) toLua;

  cfg = config.programs.neovim.lazy-nvim.mason;

  pathToModule = path: toLua (removeSuffix ".lua" cfg.luaFiles."${baseNameOf path}".name);

  pick-lsp-formatter-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "pick-lsp-formatter-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "fmbarina";
      repo = "pick-lsp-formatter.nvim";
      rev = "5c13fcac3e6845dbed0aadd9933cbe118f7877fd";
      hash = "sha256-7Gq9Z/U9lkEGZyIvvAZG2Br8wEtgcGDUrT3AJIkJH9U=";
    };
  };
in
{
  options.programs.neovim.lazy-nvim.mason =
    let
      inherit (lib.options) mkOption;
      inherit (config.programs.neovim.lazy-nvim) types;

      HandlerConfig =
        with types;
        submodule {
          options = {
            capabilities = mkOption {
              type = nullOr luaSnippet;
              default = mkLuaInline ''require("coq").lsp_ensure_capabilities().capabilities'';
            };
            on_attach = mkOption {
              type = nullOr luaSnippet;
              default = mkLuaInline ''require(${pathToModule ./on_attach.lua})'';
            };
            settings = mkOption {
              type = attrs;
              default = { };
            };
          };
        };
    in
    {
      ensureInstalled =
        with types;
        mkOption {
          type = listOf str;
          default = [ ];
        };

      handlers =
        with types;
        mkOption {
          type = nullOr (attrsOf HandlerConfig);
          default = { };
        };

      luaFiles =
        with types;
        mkOption {
          type = attrsOf (submodule {
            options = {
              name = mkOption { type = str; };
              path = mkOption { type = path; };
            };
          });
          visible = false;
          internal = true;
        };
    };

  config =
    with pkgs.vimPlugins;
    let
      inherit (builtins) listToAttrs hashFile;
      inherit (lib.lists) imap0;
      inherit (lib.attrsets)
        mergeAttrsList
        mapAttrs
        mapAttrs'
        nameValuePair
        ;

      # Highest pluginPriority loads first
      pluginPriority =
        pipe
          [
            "mason-lspconfig-nvim" # 0 -> last loaded
            "mason-null-ls-nvim"
            "none-ls-nvim" # 2 -> first loaded
          ]
          [
            (imap0 (value: name: { inherit name value; }))
            listToAttrs
          ];

      event = [
        "BufReadPre"
        "BufNewFile"
      ];

      pathToLuaFileInfo =
        path:
        let
          hash = hashFile "sha256" path;
          baseName = baseNameOf path;
          name = "${hash}-${baseName}";
        in
        {
          ${baseName} = { inherit path name; };
        };
    in
    {
      programs.neovim.lazy-nvim.mason.luaFiles =
        pipe
          [ ./on_attach.lua ]
          [ (map pathToLuaFileInfo) mergeAttrsList ];

      home.file = mapAttrs' (
        baseName:
        { name, path }:
        let
          target = ".config/nvim/lua/${name}";
        in
        nameValuePair target {
          inherit target;
          source = path;
        }
      ) cfg.luaFiles;

      programs.neovim.lazy-nvim.plugins = [
        {
          package = mason-lspconfig-nvim;

          priority = pluginPriority."mason-lspconfig-nvim";

          inherit event;

          dependencies = [
            { package = nvim-lspconfig; }
            { package = pick-lsp-formatter-nvim; }
            { package = SchemaStore-nvim; } # JSON/YAML schemas
            { package = nvim-navic; } # Context in the status bar
            {
              package = mason-nvim;
              config = true;
            }
          ];

          opts =
            let
              inherit (config.programs.neovim.lazy-nvim) toLua;

              handlers = mapAttrs (
                lang: settings:
                mkLuaInline ''
                  function()
                    require("lspconfig")[${toLua lang}].setup(${toLua settings})
                  end
                ''
              ) cfg.handlers;
            in
            {
              inherit handlers;
              ensure_installed = cfg.ensureInstalled;
              automatic_enable = true;
            };
        }

        {
          package = mason-null-ls-nvim;

          priority = pluginPriority."mason-null-ls-nvim";

          inherit event;

          dependencies = [ { package = mason-lspconfig-nvim; } ];

          opts.handlers = mkLuaInline ''
            { function() require("mason-null-ls").default_setup(source, methods) end }
          '';
        }

        {
          package = none-ls-nvim;

          priority = pluginPriority."none-ls-nvim";

          inherit event;

          dependencies = [
            { package = plenary-nvim; }
            { package = mason-null-ls-nvim; }
          ];

          config = true;
        }
      ];
    };
}

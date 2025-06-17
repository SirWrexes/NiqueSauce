{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.strings) readFile;
  inherit (lib.generators) mkLuaInline;

  pick-lsp-formatter-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "pick-lsp-formatter-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "fmbarina";
      repo = "pick-lsp-formatter.nvim";
      rev = "5c13fcac3e6845dbed0aadd9933cbe118f7877fd";
      hash = "";
    };
  };
in
{
  options.programs.neovim.lazy-nvim.mason =
    let
      inherit (lib.options) mkOption;
      inherit (config.programs.neovim.lazy-nvim) toLua types;
    in 
  {
    handler = with types; mkOption {
      type = nullOr (attrsOf (functioTo luaSnippet))
      default = _: mkLuaInline ''do end'';
    };
  };

  config =
    with pkgs.vimPlugins;
    let
      inherit (lib.lists) imap0;

      # Highest priority loads first
      priority = imap0 (i: v: { v = i; }) [
        mason-lspconfig-nvim # 0 -> last loaded
        nason-null-ls-nvim
        none-ls-nvim # 2 -> first loaded
      ];

      event = ["BufReadPre" "BufNewFile"];
    in
    {
      programs.neovim.lazy-nvim.plugins = [
        rec {
          package = mason-lspconfig-nvim;

          priority = priority.${package};

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

          # opt.handlers = require "plugins.code.mason.handlers" {
          #   lspconfig = lspconfig,
          #   capabilities = capabilities,
          #   default_on_attach = require "plugins.code.mason.default_on_attach",
          # }
          opts = {
            # TODO TODO TODO TODO TODO TODO TODO
            # I REPEAT, YOU **MUST** DO THIS
            # TODO TODO TODO TODO TODO TODO TODO
            automatic_enable = true;
          };

          config = 
            let
              inherit (builtins) hashFile;
              inherit (config) xdg;

              hash = hashfile ./on_attach.lua;
              output = xdg.configFile."nvim/lua/${hash}-on_attach.lua" (readFile ./on_attach.lua);
              on_attach = baseNameOf output;
            in 
          mkLuaInline ''
            function(_, opts)
              local masonlsp = require "mason-lspconfig"
              local capabilities = require("coq").lsp_ensure_capabilities().capabilities
              local lspconfig = require "lspconfig"
              local default_on_attach = require(${on_attach})

              masonlsp.setup(opts)
            end
          '';
        }

        rec {
          package = mason-null-ls-nvim;

          priority = priority.${package};

          inherit event;

          dependencies = [ { package = mason-lspconfig-nvim; } ];

          opts.handlers = mkLuaInline ''
            { function() require("mason-null-ls").default_setup(source, methods) end }
          '';
        }

        rec {
          package = none-ls-nvim;

          priority = priority.${package};

          inherit event;

          dependencies = [
            { package = plenary-nvim; }
            { package = mason-null-ls; }
          ];

          config = true;
        }
      ];
    };
}

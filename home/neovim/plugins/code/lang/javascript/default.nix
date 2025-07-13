{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  inherit (config.programs.neovim.lazy-nvim) toLua;

  lspconfig = config.programs.neovim.lazy-nvim.lspconfig;

  twoslash-queries-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "twoslash-queries-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "marilari88";
      repo = "twoslash-queries.nvim";
      rev = "b92622c7b71eceefabd02eef24236041069904b1";
      hash = "sha256-YGFRbceYFswAbiOrMCx8ynEkQ45MkSOm0LHccYXyuXM=";
    };
  };

  filetypes = [
    "javascript"
    "typescript"
    "javascriptreact"
    "typescriptreact"
  ];
in
{
  home.packages = with pkgs; [
    eslint_d
    prettierd
    typescript
  ];

  programs.neovim.lazy-nvim.plugins =
    with pkgs.vimPlugins;
    map (plugin: plugin // { ft = filetypes; }) [
      {
        package = twoslash-queries-nvim;

        keys =
          let
            Cmd = cmd: "<Cmd>${cmd}<Cr>";
            mkKeys = map ({ rhs, ... }@mapping: mapping // { rhs = Cmd rhs; });
          in
          mkKeys [
            {
              lhs = "<leader>tsi";
              rhs = "TwoslashQueriesInspect";
              desc = "Insert under cursor";
            }
            {
              lhs = "<leader>tsr";
              rhs = "TwoslashQueriesRemove";
              desc = "Remove all ^? comments";
            }
          ];
      }
      {
        package = typescript-tools-nvim;

        dependencies = [ { package = plenary-nvim; } ];

        opts =
          let
            options = {
              before_init = mkLuaInline ''function() vim.fn.setenv("PRETTIERD_DEFAULT_CONFIG", "${toString ./prettierrc.yaml}") end'';
              on_attach =
                mkLuaInline
                  # lua
                  ''
                    function(client, buffer)
                      ${toLua lspconfig.luaDefaults.on_attach}(client, buffer)
                      require('twoslash-queries').attach(client, buffer)
                    end
                  '';
              settings = {
                expose_as_code_action = "all";
                tsserver_file_preferences = {
                  includeInlayParameterNameHints = "literals";
                  includeInlayParameterNameHintsWhenArgumentMatchesName = false;
                  includeInlayFunctionParameterTypeHints = false;
                  includeInlayVariableTypeHints = false;
                  includeInlayVariableTypeHintsWhenTypeMatchesName = false;
                  includeInlayPropertyDeclarationTypeHints = true;
                  includeInlayFunctionLikeReturnTypeHints = false;
                  includeInlayEnumMemberValueHints = true;
                };
                jsx_close_tag = {
                  enable = true;
                  filetypes = [
                    "javascriptreact"
                    "typescriptreact"
                  ];
                };
              };
              handlers = {
                "textDocument/publishDiagnostics" = mkLuaInline ''
                  require('typescript-tools.api').filter_diagnostics {
                    80006,
                  }
                '';
              };
            };
          in
          mkLuaInline ''function() return ${toLua options} end'';
      }
    ];

  programs.neovim.lazy-nvim.none-ls.sources =
    map (source: mkLuaInline ''require('none-ls.${source}.eslint_d')'')
      [
        "diagnostics"
        "formatting"
        "code_actions"
      ];
}

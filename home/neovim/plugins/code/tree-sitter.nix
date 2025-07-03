{
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.extraPackages = with pkgs; [
    clang
    tree-sitter
    stdenv.cc.cc.lib
  ];

  programs.neovim.lazy-nvim.plugins =
    with pkgs.vimPlugins;
    let
      treesitter = nvim-treesitter.withAllGrammars;
      grammarsPath = pkgs.symlinkJoin {
        name = "nvim-treesitter-grammars";
        paths = treesitter.dependencies;
      };
    in
    [
      {
        package = treesitter;

        dependencies = [
          { package = nvim-treesitter-refactor; }
          { package = nvim-treesitter-textobjects; }
          {
            package = nvim-treesitter-context;
            opts = {
              enable = true;
              max_lines = 4;
              separator = "·";
            };

            config =
              mkLuaInline
                # lua
                ''
                  function(_, opts)
                    require("treesitter-context").setup(opts)
                    vim.cmd [[
                      hi! link TreeSitterContextSeparator SignColumn
                      hi! link TreeSittercontext          VisualNOS
                    ]]
                  end
                '';
          }
        ];

        lazy = false;

        main = "nvim-treesitter.configs";

        opts = {
          auto_install = false;
          indent.enable = true;
          highlight.enable = true;
          incremental_selection.enable = true;
          textobjects = {
            select.enable = true;
            swap.enable = true;
            lsp_interop = true;
          };
        };

        config =
          mkLuaInline
            # lua
            ''
              function(self, opts)
                vim.opt.rtp:append("${grammarsPath}")
                require(self.main).setup(opts)
              end
            '';

        keys =
          let
            peek = context: "<cmd>TSTextobjectPeekDefinitionCode ${context}<cr>";

            mkKeys = map (
              mapping:
              mapping
              // {
                mode = [
                  "n"
                  "i"
                ];
              }
            );
          in
          mkKeys [
            {
              lhs = "<C-p>if";
              rhs = peek "@function.inner";
              desc = "Peek inner function definition";
            }
            {
              lhs = "<C-p>af";
              rhs = peek "@function.outer";
              desc = "Peek outer function definition";
            }
            {
              lhs = "<C-p>ic";
              rhs = "@class.inner";
              desc = "Peek inner class definition";
            }
            {
              lhs = "<C-p>ac";
              rhs = "@class.outer";
              desc = "Peek outer class definition";
            }
          ];
      }
    ];
}

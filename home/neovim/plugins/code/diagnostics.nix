{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = trouble-nvim;

      event = "LspAttach";

      config =
        mkLuaInline
          # lua
          ''
            function(_, opts)
              require('trouble').setup(opts)

              vim.diagnostic.config {
                virtual_text = true,
                float = { source = "always" },
                update_in_insert = true,
                severity_sort = true,
                signs = {
                  text = {
                    [vim.diagnostic.severity.ERROR] = ' ',
                    [vim.diagnostic.severity.WARN ] = ' ',
                    [vim.diagnostic.severity.INFO ] = ' ',
                    [vim.diagnostic.severity.HINT ] = ' ',
                  },
                },
              }
            end
          '';

      keys =
        let
          Trouble = mode: mkLuaInline ''function() require('trouble').toggle(${toLua mode}) end'';
        in
        [
          {
            lhs = "<leader>xx";
            rhs = Trouble "diagnostics";
            desc = "Diagnostics";
          }
          {
            lhs = "<leader>xX";
            rhs = Trouble {
              source = "diagnostics";
              filter.buf = 0;
            };
            desc = "Diagnostics (buffer)";
          }
          {
            lhs = "<leader>cs";
            rhs = Trouble {
              source = "symbols";
              foucus = false;
            };
            desc = "Symbols (Trouble)";
          }
          {
            lhs = "<leader>cl";
            rhs = Trouble {
              source = "lsp";
              focus = false;
              win.position = "right";
            };
            desc = "LSP Definitions / references / ... (Trouble)";
          }
          {
            lhs = "<leader>xL";
            rhs = Trouble "loclist";
            desc = "Location List (Trouble)";
          }
          {
            lhs = "<leader>xQ";
            rhs = Trouble "qflist";
            desc = "Quickfix List (Trouble)";
          }
        ];
    }
  ];
}

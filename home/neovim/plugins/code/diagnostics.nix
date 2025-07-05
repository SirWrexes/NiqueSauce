{ pkgs, lib, ... }:

let
  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = trouble-nvim;

      cmd = "Trouble";

      keys =
        let
          Trouble = mode: "<Cmd>lua require('trouble').toggle(${toLua mode})<Cr>";
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

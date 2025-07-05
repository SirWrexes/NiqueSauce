{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = trouble-nvim;

      cmd = "Trouble";

      keys =
        let
          Trouble = cmd: "<Cmd>Trouble ${cmd}<Cr>";
        in
        [
          {
            lhs = "<leader>xx";
            rhs = Trouble "diagnostics toggle";
            desc = "Diagnostics";
          }
          {
            lhs = "<leader>xX";
            rhs = Trouble "diagnostics toggler filter .buf=0";
            desc = "Diagnostics (buffer)";
          }
          {
            lhs = "<leader>xX";
            rhs = Trouble "diagnostics toggle filter.buf=0";
            desc = "Buffer Diagnostics (Trouble)";
          }
          {
            lhs = "<leader>cs";
            rhs = Trouble "symbols toggle focus=false";
            desc = "Symbols (Trouble)";
          }
          {
            lhs = "<leader>cl";
            rhs = Trouble "lsp toggle focus=false win.position=right";
            desc = "LSP Definitions / references / ... (Trouble)";
          }
          {
            lhs = "<leader>xL";
            rhs = Trouble "loclist toggle";
            desc = "Location List (Trouble)";
          }
          {
            lhs = "<leader>xQ";
            rhs = Trouble "qflist toggle";
            desc = "Quickfix List (Trouble)";
          }
        ];
    }
  ];
}

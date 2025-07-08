{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = windows-nvim;

      dependencies = [
        { package = middleclass; }
        { package = animation-nvim; }
      ];

      event = "WinLeave";

      init =
        mkLuaInline
          # lua
          ''
            function()
              vim.o.winwidth = 10
              vim.o.winminwidth = 10
              vim.o.equalalways = false
            end
          '';

      opts = {
        autowidth = {
          enable = true;
          windwidth = 5;
          filetype.help = 2;
        };
        ignore.filetype = [
          "undotree"
          "snacks_layout_box"
        ];
        animation = {
          enable = true;
          duration = 450;
          fps = 60;
        };
      };

      keys =
        let
          mkKeys = map (
            { lhs, rhs, ... }@key:
            key
            // {
              lhs = "<C-w>${lhs}";
              rhs = "<Cmd>Windows${rhs}<Cr>";
              mode = "n";
              silent = true;
            }
          );
        in
        mkKeys [
          {
            lhs = "m";
            rhs = "Maximize";
            desc = "Maximise";
          }
          {
            lhs = "_";
            rhs = "Minimize";
            desc = "Minimise";
          }
          {
            lhs = "|";
            rhs = "MaximizeVertically";
            desc = "Maximise vertically";
          }
          {
            lhs = "=";
            rhs = "Equalize";
            desc = "Equalise";
          }
        ];
    }
  ];
}

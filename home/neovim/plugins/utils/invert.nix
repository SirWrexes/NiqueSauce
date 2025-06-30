{ lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = [
    {
      dir = "~/Repos/neovim/invert.nvim";

      keys =
      let
        mkKeys = map (
          { desc, rhs, ...}@mapping: mapping // {
            desc = "Invert: ${desc}";
            rhs = mkLuaInline 
              # lua
              ''
                function() require('invert').${rhs} end
              '';
          }
        );
      in
      [
        {
          lhs = "<leader>ii";
          rhs = "invert_at_cursor()";
          desc = "Invert: token under cursor";
        }
      ];
    }
  ];
}

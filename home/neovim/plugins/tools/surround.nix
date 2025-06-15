{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-surround;

      keys = [
        "ys"
        "ds"
        "cs"
        "S"
      ];

      init = mkLuaInline ''function() vim.keymap.del({"n"}, "S") end'';
    }
  ];
}

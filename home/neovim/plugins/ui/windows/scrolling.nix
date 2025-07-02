{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = satellite-nvim;

      event = "VeryLazy";
    }
    {
      package = nvim-scrollview;

      event = "VeryLazy";

      config = true;
    }
    {
      package = cinnamon-nvim;

      enabled = false;

      opts = {
        keymaps = {
          basic = true;
          extra = true;
        };
      };

      keys = [
        "#"
        "$"
        "*"
        "0"
        "<C-End>"
        "<C-Home>"
        "<C-b>"
        "<C-d>"
        "<C-e>"
        "<C-f>"
        "<C-i>"
        "<C-o>"
        "<C-u>"
        "<C-y>"
        "<PageDown>"
        "<PageUp>"
        "G"
        "N"
        "^"
        "g#"
        "g*"
        "gg"
        "gj"
        "gk"
        "h"
        "j"
        "k"
        "l"
        "n"
        "z+"
        "z-"
        "z."
        "z<Cr>"
        "zH"
        "zL"
        "z^"
        "zb"
        "ze"
        "zh"
        "zl"
        "zs"
        "zt"
        "zz"
        "{"
        "}"
        "<Up>"
        "<Up>"
        "<Down>"
        "<Down>"
        "<Left>"
        "<Right>"
        # B
        # A
        # Start
      ];
    }
  ];
}

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

      opts = {
        excluded_filetypes = [ "snacks_dashboard" ];
        current_only = true;
      };
    }
    {
      package = cinnamon-nvim;

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
        "gd"
        "gg"
        "gi"
        "gj"
        "gk"
        "gr"
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
        "<Left>"
        "<Right>"
        # B
        # A
        # Start
      ];
    }
  ];
}

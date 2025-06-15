{ pkgs', ... }:

{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = pkgs'.vimPlugins.colorful-winsep-nvim;

      event = "WinLeave";

      config = true;
    }
  ];
}

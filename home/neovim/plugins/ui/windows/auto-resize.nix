{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = windows-nvim;

      dependencies = [
        { package = middleclass; }
        { package = animation-nvim; }
      ];

      event = "WinLeave";

      config = true;
    }
  ];
}

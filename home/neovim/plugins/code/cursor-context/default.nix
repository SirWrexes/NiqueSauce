{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-navic;
      lazy = true;
    }
  ];

  programs.neovim.lazy-nvim.mason.defaultOnAttach = [ ./onAttach.lua ];
}

{ config, pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = pkgs.vimPlugins.nvim-notify;
      lazy = false;
    }
  ];
}

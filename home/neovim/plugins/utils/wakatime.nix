{ pkgs, lib, ... }:

{
  programs.neovim.extraPackages = with pkgs; [ wakatime-cli ];
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [ { package = vim-wakatime; } ];
}

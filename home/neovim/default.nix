{ config, pkgs, ... }:

{
  programs.neovim.enable = true;

  imports = [ ./plugins ];

  programs.neovim = {
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    viAlias = true;
    vimAlias = true;
    custonRC = ''
        set relativenumber
        set shiftwidth=2
        set tabstop=2
        set expandtab
    '';
  };
}

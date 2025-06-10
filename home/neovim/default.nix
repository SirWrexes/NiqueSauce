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
  };
}

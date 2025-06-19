{ pkgs, lib, ... }:

{
  programs.neovim.extraLuaConfig = ''

    ${lib.strings.readFile ./config.lua}

  '';
}

{ config, pkgs, ... }:

{
  imports = [ ./prompt.nix ];

  programs.fish.enable = false;

  programs.fish = {
    plugins = import ./plugins;
    generateCompletions = true;
  };
}

{ config, pkgs, ... }:

{
  programs.fish.enable = true;

  imports = [ ./prompt.nix ];

  programs.fish = {
    plugins = import ./plugins;

    generateCompletions = true;
  };
}

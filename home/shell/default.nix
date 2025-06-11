{ config, pkgs, ... }:

{
  imports = [ ./prompt.nix ];

  programs.fish.enable = false;

  programs.fish = {
    plugins = import ./plugins;
    generateCompletions = true;
    interactiveShellInit =
      let
        inherit (pkgs.lib.meta) getExe;
      in
      ''
        fish_vi_key_bindings

        set fish_greeting "Today is a good day to code avec le cul !"

        ${getExe pkgs.starship} init fish | source
      '';
  };
}

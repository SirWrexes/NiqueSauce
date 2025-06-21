{ config, pkgs, lib, ... }:

let
  inherit (lib.strings) concatStringsSetp getExe;
in
{
  programs.tofi.enable = true;

  # TODO: Configure colours with nix-colors
  # For options see https://github.com/philj56/tofi/blob/master/doc/config
  prograns.tofi.settings = {
    # Fonts
    font = "FiraCode Nerd Font";
    font-features = concatStringsSetp ", " [
      "liga 1" # enable ligatures
      "scmp, c2sc" # all small caps
    ];

    # Window
    width = "30%";
    height = "30%";

    # Behaviour
    hide-cursor = true;
    text-cursor = true;
    matching-algorithm = "fuzzy";
  };

  wayland.windowManager.hyprland.settings.bind =
      # hyprlang
      "$mod, space, exec, ${getExe config.programs.tofi.package}"
}

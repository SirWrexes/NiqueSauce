{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.meta) getExe;
in
{
  programs.tofi.enable = true;

  # TODO: Configure colours with nix-colors
  # For options see https://github.com/philj56/tofi/blob/master/doc/config
  programs.tofi.settings = {
    # Fonts
    font = "FiraCode Nerd Font";
    font-features = concatStringsSep ", " [
      "liga 1" # enable ligatures
      "scmp, c2sc" # all small caps
    ];

    # Window
    width = "30%";
    height = "30%";

    # Behaviour
    text-cursor = true;
    fuzzy-match = true;
  };

  # TODO: Monkey patch `hyprland` module to accept merging key settings
  # wayland.windowManager.hyprland.settings.bind =
  #   # hyprlang
  #   "$mod, space, exec, ${getExe config.programs.tofi.package}";
}

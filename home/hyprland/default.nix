{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # see https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#installation
    systemd.variables = pkgs.lib.attrsets.mapAttrsToList (name: value: name);
  };

  # Hint Electron apps to use native Wayland support
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.kitty.enable = true; # Required for the default config

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = import ./binds/keyboard.nix;
    bindm = import ./binds/mouse.nix;
    input = import ./input/keyboard.nix // import ./input/mouse.nix;
  };
}

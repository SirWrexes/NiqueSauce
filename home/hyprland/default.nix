{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false; # see https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#installation
  };

  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = import ./binds/keyboard.nix;
    bindm = import ./binds/mouse.nix;
    input = import ./input/keyboard.nix // import ./input/mouse.nix;
    env =
      pkgs.lib.attrsets.mapAttrsToList (name: value: "${name}, ${value}")
        (import ../env { inherit pkgs; }).unix;
  };
}

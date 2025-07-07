{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;

  graphical = config.hostConfig.graphics != "tty";
in
{
  config = mkIf graphical {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # GUI Audio control
      pavucontrol

      # Patchbay for pipewire
      helvum
    ];
  };
}

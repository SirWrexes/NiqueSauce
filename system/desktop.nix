{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.hostConfig.hasGUI {
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
      ffmpeg-full
      helvum # Patchbay for pipewire
      pavucontrol
    ];
  };
}

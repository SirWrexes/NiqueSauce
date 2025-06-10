{ config, pkgs, ... }:

with config.colorScheme.palette;
{
  # Alternative Discord client, with better performance and privacy
  # Includes Vencord out of the box
  programs.vesktop.enable = true;

  programs.vesktop.settings = {
    checkUpdates = false;
    tray = true;
    disableMinSize = true;
    splashTheming = true;
    splashBackground = "#${base00}";
    splashColor = "#${base01}";
    hardwareAcceleration = true;
  };

  programs.vesktop.vencord.settings = 
    let
      plugins = {
        MessageLogger.enabled = true;
      };
    in
    {
      autoUpdate = false;
      autoUpdateNitification = false;
      notifyAboutUpdates = false;
      disableMinSize = true;
      inherit plugins;
    };
}

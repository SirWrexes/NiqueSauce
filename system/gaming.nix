{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.options) mkEnableOption;

  isGamer = config.hostConfig.gamer;
in
{
  options.hostConfig = {
    gamer = mkEnableOption "gaming";
  };

  config = mkIf isGamer {
    programs.steam = {
      enable = true;
      extest.enable = true;
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}

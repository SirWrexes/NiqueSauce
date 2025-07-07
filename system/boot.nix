{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkIf;
  inherit (lib.options) mkOption mkPackageOption;

  boot = config.hostConfig.boot;
in
{
  options.hostConfig.boot = {
    supportsEfi =
      with types;
      mkOption {
        type = bool;
        default = true;
      };

    displayResolution =
      with types;
      mkOption {
        type = nullOr str;
        default = null;
      };

    theme = mkPackageOption pkgs "catppuccin-grub" { };
  };

  config.boot.loader = {
    efi.canTouchEfiVariables = mkIf boot.supportsEfi true;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = boot.supportsEfi;
      gfxmodeEfi = mkIf (boot.supportsEfi && boot.displayResolution != null) boot.displayResolution;
      theme = boot.theme;
    };
  };
}

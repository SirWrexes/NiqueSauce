{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkForce
    mkIf
    mkMerge
    ;
  inherit (lib.options) mkOption;
  inherit (lib.lists) head;

  cfg = config.hostConfig;

  backends = [
    "nouveau"
    "nvidia"
    "amd"
    "tty"
  ];

  mkNVidia = mkIf (cfg.graphics == "nvidia");
  mkGUI = mkIf cfg.hasGUI;
in
{
  options.hostConfig = {
    graphics =
      with types;
      mkOption {
        type = enum backends;
        default = head backends;
      };

    hasGUI =
      with types;
      mkOption {
        type = bool;
        readOnly = true;
      };
  };

  config = mkMerge [
    { hostConfig.hasGUI = mkForce (cfg.graphics != "tty"); }

    (mkGUI { hardware.graphics.enable = true; })

    (mkNVidia {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.nvidia.acceptLicence = true;
      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true; # required
        nvidiaSettings = true;
        powerManagement = {
          enable = false;
          finegrained = false;
        };
      };
    })
  ];
}

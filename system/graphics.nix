{
  config,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkIf
    mkMerge
    ;
  inherit (lib.options) mkOption;
  inherit (lib.lists) head;

  graphics = config.hostConfig.graphics;

  backends = [
    "nouveau"
    "nvidia"
    "amd"
    "tty"
  ];

  mkVidia = mkIf (graphics == "nvidia");
  mkGUI = mkIf (graphics != "tty");
in
{
  options.hostConfig = {
    graphics =
      with types;
      mkOption {
        type = enum backends;
        default = head backends;
      };
  };

  config = mkMerge [
    (mkGUI { hardware.graphics.enable = true; })
    (mkVidia {
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

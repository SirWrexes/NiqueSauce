{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.lists) optionals;

  cfg = config.hostConfig;
  packages = cfg.system.packages;

  packageListOption =
    with types;
    mkOption {
      type = listOf package;
      default = [ ];
    };

  targetUIs = [
    "GUI"
    "TUI"
  ];

  genPackageOptions = targets: genAttrs targets (_: packageListOption);
in
{
  options.hostConfig = {
    home.packages = genPackageOptions targetUIs;
    system.packages = genPackageOptions targetUIs;
  };

  imports = [
    ./figma
    ./kitty
    ./gimp
  ];

  config = {
    environment.systemPackages = optionals cfg.hasGUI packages.GUI ++ packages.TUI;
  };
}

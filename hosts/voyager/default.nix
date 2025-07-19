{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  hostConfig = {
    flakeRoot = "$XDG_CONFIG_HOME/nixos";
    boot.displayResolution = "1920x1080";
    shell = pkgs: pkgs.fish;
  };

  services.xserver.xkb = {
    layout = "fr";
    options = "compose:sclk";
  };
}

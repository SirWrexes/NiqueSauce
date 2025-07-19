{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  hostConfig = {
    flakeRoot = "$HOME/.nixos";
    graphics = "nvidia";
    boot.displayResolution = "3440x1440";
    shell = pkgs: pkgs.fish;
    gamer = true;
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
    options = "compose:sclk";
  };
}

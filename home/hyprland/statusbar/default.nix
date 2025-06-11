{
  config,
  pkgs,
  nix-colors,
  ...
}:

{
  programs.eww.enable = true;
  programs.eww.configDir = ./config;
}

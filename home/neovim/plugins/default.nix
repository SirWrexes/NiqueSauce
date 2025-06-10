{ config, pkgs, nix-colors, ... }:

{
  programs.neovim.plugins = [
    import ./colorScheme.nix { inherit nix-colors; scheme = config.colorScheme; }
  ];
}

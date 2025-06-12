{
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  inherit (config.programs) neovim;
in
{
  imports = [ ./lazy-nvim.nix ];

  neovim.lazy-nvim.enable = true;

  neovim.lazy-nvim = {
    luaMiltiline = true;
  };
}

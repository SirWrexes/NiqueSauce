{ config, lib, ... }:

let
  inherit (lib.lists) optionals;

  gui = optionals (config.hostConfig.graphics != "tty") [
    ./gimp.nix
  ];

  tui = [ ];
in
{
  imports = [ ./gimp.nix ];
}

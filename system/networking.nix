{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (lib.strings) toLower;

  host = config.hostConfig;
in
{
  options.hostConfig = {
    name =
      with types;
      mkOption {
        type = addCheck str (name: toLower name == name);
      };
  };

  config = {
    networking.networkmanager.enable = true;
    networking.hostName = host.name;
  };
}

{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (lib.strings) toLower;

  host = config.hostConfig;

  lowercaseStr =
    with types;
    (addCheck str (name: toLower name == name))
    // {
      description = "lowercase string";
    };
in
{
  options.hostConfig = {
    name = mkOption {
      type = lowercaseStr;
    };
  };

  config = {
    networking.networkmanager.enable = true;
    networking.hostName = host.name;
  };
}

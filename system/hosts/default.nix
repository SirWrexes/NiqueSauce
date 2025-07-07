{ config, lib, ... }:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;

  host = config.hostConfig;
in
{
  options.hostConfig = {
    name =
      with types;
      mkOption {
        type = str;
        readOnly = true;
      };
  };
}

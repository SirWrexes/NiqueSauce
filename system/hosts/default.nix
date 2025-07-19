{ lib, ... }:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options.hostConfig = {
    name =
      with types;
      mkOption {
        type = str;
        readOnly = true;
      };

    flakeRoot =
      with types;
      mkOption {
        type = str;
        readOnly = true;
      };
  };
}

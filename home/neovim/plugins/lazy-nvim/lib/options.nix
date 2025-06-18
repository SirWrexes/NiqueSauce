{ lib }:

let
  inherit (lib.options) mkOption;

  types = import ./types.nix { inherit lib; };
in
lib.options
// {
  mkDescribedEnableOption =
    name: extraDescription:
    with types;
    mkOption {
      type = bool;
      default = false;
      description = "Whether to enable ${name}.\n" + extraDescription;
      example = "true";
    };
}

{ pkgs, ... }:

let
  inherit (builtins) map foldl' typeOf;
  sets = { inherit (pkgs.lib.attrsets) mergeAttrsList mapAttrs; };
  files = { inherit (pkgs.lib.fileset) toList fileFilter; };
  strings = { inherit (pkgs.lib.strings) concatStringsSep; };

  joinList = list: strings.concatStringsSep ":" list;

  unixifyValue = value: if typeOf value == "list" then joinList value else toString value;
  unixifySet = set: sets.mapAttrs (key: value: unixifyValue value) set;

  findExtraVars =
    searchPath:
    files.fileFilter (
      {
        name,
        type,
        hasExt,
        ...
      }:
      type == "regular" && hasExt "nix" && baseNameOf name != "default.nix"
    ) searchPath;

  extraVarsPaths = files.toList (findExtraVars ./.);
  extraVarsList = map (vars: import vars) extraVarsPaths;
  extraVars = sets.mergeAttrsList extraVarsList;
in
rec {
  raw = {
    BROWSER = "firefox";
    TERMINAL = "kitty";
  } // extraVars;

  unix = unixifySet raw;
}

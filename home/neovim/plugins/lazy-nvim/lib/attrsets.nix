{ lib }:

let
  inherit (lib.attrsets) filterAttrs;
in
lib.attrsets // { stripNulls = filterAttrs (_: v: v != null); }

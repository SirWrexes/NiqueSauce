{ lib }:

let
  inherit (builtins) typeOf;

  inherit (lib.strings) concatStringsSep;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.trivial) pipe;

  inherit (import ./. { inherit lib; }) toLua;
  inherit (import ./attrsets.nix { inherit lib; }) foldlAttrs stripNulls;
  inherit (import ./types.nix { inherit lib; }) isLuaInline;
in
rec {
  trasnformRhs = rhs: if isLuaInline rhs then rhs.expr else toLua rhs;

  stripNonOpts =
    key:
    removeAttrs key [
      "lhs"
      "rhs"
      "desc"
    ];

  foldOpts = foldlAttrs (
    acc: name: value:
    acc ++ [ ''[${toLua name}] = ${toLua value}'' ]
  ) [ ];

  transformOpts =
    key:
    pipe key [
      stripNonOpts
      stripNulls
      foldOpts
    ];

  transformNonString =
    prefix:
    {
      lhs,
      rhs ? null,
      desc ? null,
      ...
    }@key:
    let
      parts =
        [ (toLua lhs) ]
        ++ (if rhs != null then [ (trasnformRhs rhs) ] else [ ])
        ++ (if desc != null then [ ''["desc"] = "${prefix}: ${desc}"'' ] else [ ])
        ++ (transformOpts key);
    in
    mkLuaInline ''
      {
        ${concatStringsSep ",\n" parts}
      }
    '';

  toLazyKey = prefix: key: if typeOf key == "string" then key else transformNonString prefix key;
}

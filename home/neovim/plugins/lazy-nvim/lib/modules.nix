{ lib }:

let
  inherit (builtins) hashString readFile;

  inherit (lib.strings) replaceStrings;
  inherit (lib.attrsets) mergeAttrsList;
in
rec {
  generatedModulesDir = "generated/lazy-nvim";

  toModule =
    subpath:
    {
      name,
      text ? null,
      source ? null,
    }:
    let
      content =
        if text != null then
          text
        else if source != null then
          readFile source
        else
          throw ''No text or source provided.'';
      hash = hashString "sha256" content;
      identifier = replaceStrings [ "." ] [ "-" ] "${hash}-${name}";
      target = ".config/nvim/lua/${generatedModulesDir}/${subpath}/${identifier}.lua";
      requirePath =
        replaceStrings [ "/" ] [ "." ]
          "${generatedModulesDir}${if subpath != "." then "/${subpath}" else ""}/${identifier}";
    in
    {
      ${requirePath} = {
        inherit target;
        text = content;
      };
    };

  toModules = subpath: list: mergeAttrsList (map toModule subpath list);
}

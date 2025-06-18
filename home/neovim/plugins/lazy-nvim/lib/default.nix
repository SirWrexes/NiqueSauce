{ lib }:

let
  inherit (lib.attrsets) mergeAttrsList;
  imported = mergeAttrsList (
    map
      (file: { "${lib.strings.removeSuffix ".nix" (baseNameOf file)}" = import file { inherit lib; }; })
      [
        ./attrsets.nix
        ./keys.nix
        ./modules.nix # Lua requireable modules
        ./options.nix
        ./plugins.nix
        ./submodules.nix # Nix submodules
        ./types.nix
      ]
  );
in
{
  toLua = lib.generators.toLua { };

  inherit (imported)
    attrsets
    keys
    modules
    options
    plugins
    submodules
    types
    ;
}

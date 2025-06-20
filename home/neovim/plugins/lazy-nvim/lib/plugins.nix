{ lib }:

let
  inherit (lib.attrsets) mergeAttrsList;
  inherit (lib.lists) concatMap filter unique;
  inherit (lib.strings) getName;
  inherit (lib.trivial) pipe throwIf;

  inherit (import ./. { inherit lib; }) toLua;
  inherit (import ./attrsets.nix { inherit lib; }) stripNulls;

  lazykeys = import ./keys.nix { inherit lib; };
  modules = import ./modules.nix { inherit lib; };
in
rec {
  filterDisabled = filter (
    {
      enabled ? false,
      cond ? false,
      ...
    }:
    enabled != false && cond != false
  );

  ensureHasPackageOrDir =
    {
      package ? null,
      dir ? null,
      name ? null,
      ...
    }@plugin:
    throwIf (package == null && dir == null) ''
      No package or dir attribute provided for ${
        if name != null then name else "(plugin with no given name)"
      }.
    '' plugin;

  setName =
    {
      name ? null,
      package ? null,
      dir ? null,
      ...
    }@plugin:
    plugin
    // {
      name =
        if name != null then
          name
        else if package != null then
          getName package
        else
          baseNameOf dir;
    };

  setDir =
    {
      package ? null,
      dir ? null,
      ...
    }@plugin:
    plugin // { dir = if dir != null then dir else package; };

  nullifyPackageAttribute = plugin: plugin // { package = null; };

  prepareKeys =
    {
      name,
      keys ? null,
      ...
    }@plugin:
    plugin // (if keys != null then { keys = map (lazykeys.toLazyKey name) keys; } else { });

  prepareDependencies =
    {
      dependencies ? null,
      ...
    }@plugin:
    plugin // (if dependencies == null then { } else { dependencies = prepare dependencies; });

  prepare =
    plugins:
    map (
      plugin:
      pipe plugin [
        ensureHasPackageOrDir
        setName
        setDir
        prepareKeys
        prepareDependencies
        stripNulls
      ]
    ) (filterDisabled plugins);

  removePackageAttribute = map (
    {
      dependencies ? null,
      ...
    }@plugin:
    (removeAttrs plugin [ "package" ])
    // (if dependencies != null then { dependencies = removePackageAttribute dependencies; } else { })
  );

  gatherPackages =
    plugins:
    unique (
      concatMap (
        {
          package ? null,
          dependencies ? null,
          enabled ? null,
          cond ? null,
          ...
        }:
        if enabled != false && cond != false then
          (if package != null then [ package ] else [ ])
          ++ (if dependencies != null then gatherPackages dependencies else [ ])
        else
          [ ]
      ) plugins
    );

  toModule =
    { name, ... }@plugin:
    modules.toModule "spec" {
      inherit name;
      text = ''return ${toLua plugin}'';
    };

  toModules = specs: mergeAttrsList (map toModule specs);
}

{ lib }:

let
  inherit (builtins) hashString typeOf readFile;
  inherit (lib.attrsets) filterAttrs mergeAttrsList foldlAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) filter concatMap unique;
  inherit (lib.strings)
    concatStringsSep
    getName
    hasSuffix
    replaceStrings
    ;
  inherit (lib.trivial) throwIf pipe;
in
rec {
  toLua = lib.generators.toLua { };

  types =
    lib.types
    // (with lib.types; rec {
      pathIsLua = path: hasSuffix ".lua" "${path}";

      luaFile = addCheck path (pathIsLua) // {
        name = "luaFile";
        description = "Path to a Lua source file";
      };

      luaSnippet = either luaInline luaFile;

      luaPredicate = either bool luaSnippet;

      isLuaInline = x: typeOf x == "set" && isType "lua-inline" x;

      readLuaSnippet = x: if typeOf x == "path" && pathIsLua x then mkLuaInline (readFile x) else x;

      onlyTrue = addCheck bool (x: x) // {
        name = "boolTrue";
        description = "A boolean value that can only be true";
      };
    });

  attrsets = {
    stripNulls = filterAttrs (_: v: v != null);
  };

  keys = rec {
    trasnformRhs = rhs: if types.isLuaInline rhs then rhs.expr else toLua rhs;

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
        attrsets.stripNulls
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
  };

  plugins =
    let
      lazykeys = keys; # Renamed binding to avoid clashing with plugins' `keys` attribute
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
            attrsets.stripNulls
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
              package,
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
    };

  modules = rec {
    generatedModulesDir = "generated/lazy-nvim/spec";

    toModule =
      let
        transform =
          { name, ... }@plugin:
          let
            text = ''return ${toLua plugin}'';
            hash = hashString "sha256" text;
            identifier = replaceStrings [ "." ] [ "-" ] "${hash}-${name}";
            target = ".config/nvim/lua/${generatedModulesDir}/${identifier}.lua";
            requirePath = replaceStrings [ "/" ] [ "." ] "${generatedModulesDir}/${identifier}";
          in
          {
            ${requirePath} = { inherit text target; };
          };
      in
      spec: if typeOf spec == "set" then transform spec else mergeAttrsList (map transform spec);
  };
}

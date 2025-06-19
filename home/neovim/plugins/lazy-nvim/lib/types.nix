{ lib }:

let
  inherit (builtins) readFile typeOf;

  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) hasSuffix;
  inherit (lib.types) addCheck;
in
lib.types
// (with lib.types; rec {
  pathIsLua = path: hasSuffix ".lua" "${path}";

  luaFile = addCheck path pathIsLua // {
    name = "lua-file";
    description = "path to a Lua source file";
  };

  luaSnippet = either luaInline luaFile;

  luaPredicate = either bool luaSnippet;

  isLuaInline = x: typeOf x == "set" && isType "lua-inline" x;

  readLuaSnippet = x: if typeOf x == "path" && pathIsLua x then mkLuaInline (readFile x) else x;

  onlyTrue = addCheck bool (x: x) // {
    name = "boolTrue";
    description = "A boolean value that can only be true";
  };
})

{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) readDir;
  inherit (lib.trivial) pipe;
  inherit (lib.strings) readFile hasSuffix concatStringsSep;
  inherit (lib.attrsets) filterAttrs attrNames;

  concat = concatStringsSep "\n";

  getFilesWithSuffix =
    suffix: dir:
    pipe (readDir dir) [
      (filterAttrs (path: type: type == "regular" && hasSuffix suffix path))
      attrNames
      (map (path: dir + "/${path}"))
    ];

  readFilesWithSuffix = suffix: dir: map readFile (getFilesWithSuffix suffix dir);
in
{
  imports = [ ./plugins ];

  programs.neovim.enable = true;

  programs.neovim = {
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.neovim.extraConfig = ''

    ${concat (readFilesWithSuffix ".vim" ./vim.d)}

  '';

  programs.neovim.extraLuaConfig = ''

    ${concat (readFilesWithSuffix ".lua" ./vim.d)}

  '';
}

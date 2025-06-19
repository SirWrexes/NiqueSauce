# Credit: https://github.com/MattSturgeon/nix-config/commit/b8aa42d6c01465949ef5cd9d4dc086d4eaa36793

{
  self,
  system ? builtins.currentSystem,
}:

let
  # Reimplementation of `lib.lists.dropEnd 1` using builtins
  dropLast =
    list:
    let
      len = builtins.length list;
      dropped = builtins.genList (builtins.elemAt list) (len - 1);
    in
    if list == [ ] || len == 1 then [ ] else dropped;

  # Walk up the directory path, looking for a flake.nix file
  # Called with an absolute filepath
  findFlake =
    dir:
    let
      isPart = part: builtins.isString part && part != "" && part != ".";
      parts = builtins.filter isPart (builtins.split "/+" dir);
    in
    findFlake' parts;

  # Underlying impl of findFlake
  # Called with a list path instead of a string path
  findFlake' =
    parts:
    let
      dir = "/" + builtins.concatStringsSep "/" parts;
      files = builtins.readDir dir;
      isFlake = files."flake.nix" or null == "regular";
      parent = dropLast parts;
    in
    if parts == [ ] then
      null
    else if isFlake then
      dir
    else
      findFlake' parent;

  # Path to the local flake, or null
  path = findFlake (builtins.getEnv "PWD");
in
{
  inherit system self path;

  local = if path == null then null else builtins.getFlake path;
  global = builtins.getFlake self;
}

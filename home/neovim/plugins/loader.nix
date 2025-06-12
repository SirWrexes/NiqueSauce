{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) types;

  cfg = config.neovim.loader;

  types.required = T: T // { check = (v: v != null); };
  types.luaPredicate =
    with types;
    mkOptionType {
      name = "Lua.Predicate";
      type = oneOf [
        boolean
        string
        luaInline
      ];
      description = "boolean value or Lua function returning boolean";
      descriptionClass = "conjunction";
    };

  opt = type: extraConfig: mkOption (extraConfig // { inherit type; });

  # https://github.com/folke/lazy.nvim/blob/6c3bda4aca61a13a9c63f1c1d1b16b9d3be90d7a/lua/lazy/types.lua#L51
  PluginCore =
    with lib.types;
    let
      inherit (builtins) typeOf;
      inherit (lib.generators) toLua;
      apply =
        predicate:
        if typeOf predicate == "string" then
          mkLuaInline predicate
        else if predicate == "boolean" then
          toLua predicate
        else
          predicate;
    in
    {
      name = opt (required str) { description = "Display name and name used for the config files."; };
      dir = opt (required package) {
        description = "Nix package for the plugin. If it doesn't exist, make one!";
      };
      lazy = opt boolean { };
      enabled = opt luaPredicate { inherit apply; };
      cond = opt luaPredicate { inherit apply; };
      optional = opt boolean {
        description = "If set, then this plugin will not be added unless it is added somewhere else.";
      };
      priority = opt number { description = "Virtual plugins won't be installed or added to the rtp."; };
    };
in
{
  options.neovim.loader = {
    enable = mkEnableOption "Use NeoVim plugins";
  };

  config = mkIf cfg.enable {
    package = pkgs.vimPlugins.lazy-vim;

    # Make laziness opt-out by default
    lazy = true;

    # Disable automatic updates: Impure as hell
    checker.enable = false;

    # Don't let Lazy install missing plugins
    # A missing dependcy or plugin must be an error since they're
    # managed inside the nix flake.
    install.missing = false;
  };
}

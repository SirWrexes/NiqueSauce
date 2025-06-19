{ lib, config, ... }:

let
  lazylib = import ./lib { inherit lib; };
  cfg = config.programs.neovim.lazy-nvim;
in
{
  options.programs.neovim.lazy-nvim =
    let
      inherit (lib.options) mkOption;
      inherit (lazylib) types;
      inherit (lazylib.submodules) LazySpec;
    in
    {
      plugins =
        with types;
        mkOption {
          type = nullOr (listOf LazySpec);
          default = [ ];
          apply = lazylib.plugins.prepare;
        };

      spec =
        with types;
        mkOption {
          type = listOf luaInline;
          default = { };
          internal = true;
        };
    };

  config =
    let
      inherit (lib.attrsets) attrNames;
      inherit (lib.generators) mkLuaInline;
      inherit (lazylib.plugins) removePackageAttribute gatherPackages toModules;
      modules = toModules (removePackageAttribute cfg.plugins);
    in
    lib.mkIf cfg.enable {
      programs.neovim.extraPackages = gatherPackages cfg.plugins;
      home.file = modules;
      programs.neovim.lazy-nvim.spec = map (module: mkLuaInline ''require("${module}")'') (
        attrNames modules
      );
    };
}

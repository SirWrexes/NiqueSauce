{
  root,
  osConfig,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim = {
    extraPackages = with pkgs; [ nixd ];

    lazy-nvim.treesitter.parsers = tsparsers: with tsparsers; [ nix ];

    lazy-nvim.plugins = [
      {
        package = pkgs.nixd;

        ft = "nix";

        opts =
          let
            inherit (builtins) toFile toJSON;
            inherit (osConfig.networking) hostName;

            wrapper = toFile "expr.nix" ''
              import ${./findFlake.nix} {
                self = ${toJSON root};
                system = ${toJSON pkgs.stdenv.hostPlatform.system};
              }
            '';

            withFlakes = expr: "with import ${wrapper}; ${expr}";
          in
          {
            cmd = [ "nixd" ];
            settings.nixd = {
              nixpkgs.expr = withFlakes "import (if local ? lib.version then local else local.inputs.nixpkgs or global.inputs.nixpkgs) {}";
              options = rec {
                flake-parts.expr = withFlakes "local.debug.options or global.debug.options";
                nixos.expr = withFlakes "global.nixosConfigurations.${hostName}.options";
                home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions []";
              };
            };
          };

        config = mkLuaInline ''
          function(_, opts) require("lspconfig").nixd.setup(opts) end
        '';
      }
    ];
  };
}

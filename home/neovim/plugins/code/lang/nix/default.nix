{
  root,
  osConfig,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    stylua
  ];

  programs.neovim.lazy-nvim.lspconfig.servers.nixd = {
    package = pkgs.nixd;

    ft = "nix";

    dependencies = with pkgs.vimPlugins; [
      {
        package = hmts-nvim;
        dependencies = [ { package = nvim-treesitter; } ];
      }
    ];

    opts =
      let
        inherit (builtins) toFile toJSON;
        inherit (osConfig.networking) hostName;

        wrapper =
          toFile "expr.nix" # nix
            ''
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
  };
}

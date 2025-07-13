{
  root,
  osConfig,
  pkgs,
  lib,
  ...
}:

let
  server = pkgs.nixd;
  exe = lib.meta.getExe server;
in
{
  home.packages = [ server ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = hmts-nvim;
      dependencies = [ { package = nvim-treesitter; } ];
      ft = "nix";
    }
  ];

  programs.neovim.lazy-nvim.lspconfig.servers.nixd = {
    filetypes = [ "nix" ];

    cmd = [ exe ];

    cmd_env = {
      NIXPKGS_ALLOW_UNFREE = if osConfig.nixpkgs.config.allowUnfree or false then 1 else 0;
    };

    settings.nixd =
      let
        inherit (builtins) toFile toJSON;
        inherit (osConfig.networking) hostName;

        wrapper =
          toFile "nixd-expr.nix" # nix
            ''
              import ${./findFlake.nix} {
                self = ${toJSON root};
                system = ${toJSON pkgs.stdenv.hostPlatform.system};
              }
            '';

        withFlakes = expr: "with import ${wrapper}; ${expr}";
      in
      {
        nixpkgs.expr =
          withFlakes
            # nix
            "import (if local ? lib.version then local else local.inputs.nixpkgs or global.inputs.nixpkgs) {}";
        options = rec {
          flake-parts.expr = withFlakes "local.debug.options or global.debug.options";
          nixos.expr = withFlakes "global.nixosConfigurations.${hostName}.options";
          home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions []";
        };
      };
  };
}

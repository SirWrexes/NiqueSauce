{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  nvim-treehopper = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-treehopper";
    src = pkgs.fetchFromGitHub {
      owner = "mfussenegger";
      repo = "nvim-treehopper";
      rev = "c8e8667ad861585577e95c36a02c9b7d5ce7230b";
      hash = "sha256-3K/jJ1vz7HqXBFAN8KO9kz1wJ0WtdX42Zyb4ABVEUjw=";
    };
  };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-treehopper;

      dependencies = [ { package = nvim-treesitter; } ];

      keys = [
        {
          lhs = "@";
          rhs = mkLuaInline ''
            function() require("tsht").nodes() end
          '';
          desc = "Start";
          mode = [
            "n"
            "v"
            "o"
          ];
        }
      ];
    }
  ];
}

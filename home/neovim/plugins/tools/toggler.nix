{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  smart-toggler = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-toggler-smart";
    src = pkgs.fetchFromGitHub {
      owner = "TSmigielski";
      repo = "nvim-toggler";
      rev = "c6e77194361fbf925d8b69af7e9e85ff92d9e1e0";
      hash = "sha256-cSsCgFR/jAEEycpj/0pcXboCwt+HM4xB3mtA9/sxZdk=";
    };
  };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = smart-toggler;

      keys = [
        {
          lhs = "<leader>i";
          rhs = mkLuaInline ''
            function() require("nvim-toggler").toggle() end
          '';
        }
      ];

      opts.inverses = {
        "based" = "cringe";
        "inner" = "outer";
        "true" = "false";
        "<" = ">";
        "<=" = ">=";
        "&&" = "||";
        "old" = "new";
        "min" = "max";
      };
    }
  ];
}

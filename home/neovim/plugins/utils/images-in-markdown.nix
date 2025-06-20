{ pkgs, lib, ... }:

{
  programs.neovim = {
    extraLuaPackages = luaPkgs: with luaPkgs; [ magick ];
    extraPackages = with pkgs; [ imagemagick ];
  };

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = image-nvim;

      dependencies = [ { package = nvim-treesitter; } ];

      ft = [
        "markdown"
        "vimwiki"
        "norg"
      ];

      config = true;
    }
  ];
}

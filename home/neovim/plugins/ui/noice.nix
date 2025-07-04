{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = noice-nvim;

      dependencies = [
        { package = nvim-treesitter; }
        { package = nui-nvim; }
      ];

      event = "VeryLazy";

      opts = { };
    }
  ];
}

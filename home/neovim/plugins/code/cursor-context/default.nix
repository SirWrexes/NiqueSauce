{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-navic;
      lazy = true;
    }
  ];

  programs.neovim.lazy-nvim.lspconfig.defaultOnAttach = [ ./onAttach.lua ];
}

{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = startup-nvim;

      lazy = false;

      priority = 1000;

      dependencies = [
        { package = plenary-nvim; }
        { package = telescope-nvim; }
      ];

      opts.theme = "dashboard";
    }
  ];
}

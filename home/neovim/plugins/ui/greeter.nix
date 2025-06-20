{ pkgs, ... }:

# TODO: Find a way to make it work with the current LazyNvim trick of using VimEnter
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

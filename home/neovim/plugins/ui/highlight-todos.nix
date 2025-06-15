{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = todo-comments-nvim;

      dependencies = [ { package = plenary-nvim; } ];

      config = true;
    }
  ];
}

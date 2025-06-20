{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = presence-nvim;

      opts = {
        neovim_image_test = "You just lost The Game";
        enable_line_number = true;
      };
    }
  ];
}

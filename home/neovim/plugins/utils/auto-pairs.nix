{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-autopairs;

      event = "Syntax *";

      opts.check_ts = true;
    }
  ];
}

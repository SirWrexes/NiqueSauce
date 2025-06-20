{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-autopairs;

      event = "InsertEnter";

      opts.check_ts = true;
    }
  ];
}

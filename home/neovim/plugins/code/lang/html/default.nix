{ pkgs, ... }:

{
  home.packages = with pkgs; [ superhtml ];

  programs.neovim.lazy-nvim.lspconfig.servers.superhtml.enable = true;
}

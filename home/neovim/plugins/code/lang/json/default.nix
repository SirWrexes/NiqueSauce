{ pkgs, lib, ... }:

let
  server.html = pkgs.vscode-langservers-extracted;
in
{
  home.packages = lib.attrsets.attrValues server;
  programs.neovim.lazy-nvim.lspconfig.servers.jsonls.enable = true;
}

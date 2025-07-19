{ pkgs, lib, ... }:

let
  server.html = pkgs.vscode-langservers-extracted;
  server.superhtml = pkgs.superhtml;
  server.htmx = pkgs.htmx-lsp;
in
{
  home.packages = lib.attrsets.attrValues server;

  programs.neovim.lazy-nvim.lspconfig.servers = {
    html.enable = true;
    superhtml.enable = true;
    htmx.enable = true;
  };
}

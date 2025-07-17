{ pkgs, lib, ... }:

let
  server.html = pkgs.superhtml;
  exe.html = lib.meta.getExe server.html;

  server.htmx = pkgs.htmx-lsp;
  exe.htmx = lib.meta.getExe server.htmx;
in
{
  home.packages = lib.attrsets.attrValues server;

  programs.neovim.lazy-nvim.lspconfig.servers = {
    superhtml.cmd = [ exe.html ];
    htmx.cmd = [ exe.htmx ];
  };
}

{ pkgs, lib, ... }:

let
  server = pkgs.taplo;
  exe = lib.meta.getExe server;
in
{
  home.packages = [ server ];

  programs.neovim.lazy-nvim.lspconfig.servers.taplo = {
    cmd = [
      exe
      "lsp"
      "stdio"
    ];
  };
}

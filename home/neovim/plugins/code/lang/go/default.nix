{ pkgs, lib, ... }:

let
  server = pkgs.gopls;
  exe = lib.meta.getExe server;
in
{
  home.packages = [ server ];

  programs.neovim.lazy-nvim.lspconfig.servers.gopls = {
    cmd = [ exe ];
  };
}

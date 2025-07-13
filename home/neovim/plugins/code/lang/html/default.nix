{ pkgs, lib, ... }:

let
  server = pkgs.superhtml;
  exe = lib.meta.getExe server;
in
{
  home.packages = [ server ];

  programs.neovim.lazy-nvim.lspconfig.servers.superhtml = {
    cmd = [ exe ];
  };
}

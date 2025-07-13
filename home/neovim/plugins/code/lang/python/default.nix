{ pkgs, lib, ... }:

let
  server = pkgs.pyright;
  exe = lib.meta.getExe server;
in
{
  home.packages = with pkgs; [ pyright ];

  programs.neovim.lazy-nvim.lspconfig.servers.pyright = {
    cmd = [ exe ];
    filetypes = [ "python" ];
  };
}

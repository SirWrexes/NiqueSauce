{ pkgs, lib, ... }:

let
  cmd = [
    (lib.meta.getExe pkgs.gopls)
  ];
in
{
  home.packages = with pkgs; [ gopls ];

  programs.neovim.lazy-nvim.lspconfig.servers.gopls = {
    inherit cmd;
  };
}

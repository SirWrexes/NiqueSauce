{ pkgs, ... }:

{
  home.packages = with pkgs; [ pyright ];

  programs.neovim.lazy-nvim.lspconfig.servers.pyright = {
    cmd = [ "pyright" ];
    filetypes = [ "python" ];
  };
}

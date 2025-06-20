{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.lspconfig.servers.pyright = with pkgs; {
    package = pyright;

    ft = "python";
  };
}

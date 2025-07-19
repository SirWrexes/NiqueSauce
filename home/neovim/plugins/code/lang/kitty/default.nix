{ pkgs, ... }:

let
  vim-kitty = pkgs.vimUtils.buildVimPlugin {
    name = "vim-kitty";
    src = pkgs.fetchFromGitHub {
      owner = "fladson";
      repo = "vim-kitty";
      rev = "5c3efc79af70dc2c22cad03e6a7374a5f81205d9";
      hash = "sha256-cJIfXv3ImkDlgud/y3Zz4NLWLi65zxcNE5JVGTZlqKo=";
    };
  };
in
{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = vim-kitty;
      ft = "kitty";
    }
  ];
}

{ ... }:

{
  programs.neovim.lazy-nvim.enable = true;

  imports = [
    ./lazy-nvim.nix

    ./apis
    ./ui
    ./code
  ];
}

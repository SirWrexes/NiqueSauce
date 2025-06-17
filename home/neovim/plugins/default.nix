{ ... }:

{
  programs.neovim.lazy-nvim.enable = true;

  imports = [
    ./lazy-nvim

    ./apis
    ./code
    ./tools
    ./ui
  ];
}

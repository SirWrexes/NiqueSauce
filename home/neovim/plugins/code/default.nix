{ lib, ... }:

{
  imports = [
    ./lang

    ./code-actions-menu.nix
    ./comment.nix
    ./completion.nix
    ./tree-hopper.nix
    ./tree-sitter.nix
  ];

  programs.neovim.lazy-nvim.mason = {
    enable = true;
    defaultOnAttach = ./defaultLspOnAttach.lua;
  };
}

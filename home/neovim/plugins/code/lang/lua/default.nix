{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.treesitter.parsers = tsparsers: with tsparsers; [ lua ];
}

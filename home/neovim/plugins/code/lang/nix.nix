{ pkgs, lib, ... }:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      cargo # Required to install `nil` LSP
    ];

    lazy-nvim = {
      treesitter.parsers = tsparsers: with tsparsers; [ nix ];
      mason.ensureInstalled = [ "nil_ls" ];
    };
  };
}

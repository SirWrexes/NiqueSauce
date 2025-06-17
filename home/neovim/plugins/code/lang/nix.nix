{ pkgs, lib, ... }:

{
  programs.neovim = {
    extraPackages = with pkgs; [
      cargo # Required to install `nil` LSP
    ];

    lazy-nvim = {
      treesitter.parsers = tsparsers: with tsparsers; [ nix ];
      mason =
        let
          ls = "nil_ls";
        in
        {
          ensureInstalled = [ ls ];
          handlers.${ls} = { };
        };
    };
  };
}

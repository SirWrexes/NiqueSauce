{ ... }:

{
  imports = [ ./lazy-nvim.nix ];

  programs.neovim.lazy-nvim = {
    enable = true;
    #    luaMultiline = true;
  };
}

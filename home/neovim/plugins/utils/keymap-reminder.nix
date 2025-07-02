{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = which-key-nvim;

      event = "VeryLazy";

      init =
        mkLuaInline
          # lua
          ''
            function()
              vim.o.timeout = true
              vim.o.timeoutlen = 300
            end
          '';

      opts = {
        win.border = "rounded";
      };
    }
  ];
}

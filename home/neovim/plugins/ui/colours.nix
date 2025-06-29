{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = pkgs.vimPlugins.tinted-vim;

      priority = 1000;

      lazy = false;

      init = mkLuaInline ''
        function()
          vim.g.tinted_background_transparent = 1
          vim.opt.termguicolors = true
        end
      '';

      config = mkLuaInline ''
        function()
          vim.cmd.colorscheme 'base24-ic-orange-ppl'
        end
      '';
    }
  ];
}

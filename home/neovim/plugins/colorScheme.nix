{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = pkgs.vimPlugins.tinted-vim;
      priority = 1000;
      lazy = false;
      init = lib.generators.mkLuaInline ''
        function()
          vim.cmd.colorscheme 'base24-ic-orange-ppl'
        end
      '';
    }
  ];
}

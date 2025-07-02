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

      init =
        mkLuaInline
          # lua
          ''
            function()
              vim.g.tinted_background_transparent = 0
              vim.opt.termguicolors = true
            end
          '';

      config =
        mkLuaInline
          # lua
          ''
            function(_, opts)
              vim.cmd [[
                colorscheme base24-ic-orange-ppl

                hi! link StatusLine   Comment
                hi! link StatusLineNC Comment

                hi! link NormalFloat Normal
                hi! link FloatBorder Normal
              ]]

              local hl, name
              local Normal = vim.api.nvim_get_hl(0, { name = "Normal" })
              for _, hi in ipairs { "Error", "Warn", "Info", "Hint", "Ok" } do
                name = "DiagnosticFloating" .. hi
                hl = vim.api.nvim_get_hl(0, { name = name })
                hl.bg      = Normal.bg
                hl.ctermbg = Normal.ctermbg
                vim.api.nvim_set_hl(0, name, hl)
              end
            end
          '';
    }
  ];
}

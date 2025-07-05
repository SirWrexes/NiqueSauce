{
  config,
  pkgs,
  pkgs',
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lualine-nvim;

      dependencies = [
        { package = pkgs'.vimPlugins.noice-nvim; }
        { package = snacks-nvim; }
        { package = bufferline-nvim; }
      ];

      event = "VeryLazy";

      init =
        mkLuaInline
          # lua
          ''
            function()
              vim.g.lualine_laststatus = vim.o.laststatus
              if vim.fn.argc(-1) > 0 then
                -- set an empty statusline till lualine loads
                vim.o.statusline = " "
              else
                -- hide the statusline on the starter page
                vim.o.laststatus = 0
              end
            end
          '';

      opts = ./options.lua;
    }
  ];
}

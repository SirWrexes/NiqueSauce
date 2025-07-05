{
  pkgs,
  pkgs',
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs'.vimPlugins; [
    {
      package = noice-nvim;

      dependencies = [
        { package = pkgs.vimPlugins.nvim-treesitter; }
        { package = nui-nvim; }
      ];

      event = "VeryLazy";

      opts = {
        presets = {
          bottom_search = true;
          lsp_doc_border = true;
          long_message_to_split = true;
          command_palette = true;
        };
      };

      keys = [
        {
          lhs = "<S-CR>";
          rhs =
            mkLuaInline
              # lua
              ''
                function()
                  require('noice').redirect(vim.fn.getcmdline())
                end
              '';
          mode = "c";
          desc = "Redirect commandline";
        }
      ];
    }
  ];
}

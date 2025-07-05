{
  pkgs,
  pkgs',
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };
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

      keys =
        let
          mkScrollKeys = map (
            key:
            key
            // {
              mode = [
                "n"
                "i"
                "s"
              ];
              expr = true;
            }
          );
          scrollStep = "4";
        in
        (mkScrollKeys [
          rec {
            lhs = "<C-f>";
            rhs =
              mkLuaInline
                # lua
                ''
                  function()
                    if not require('noice').scroll(${scrollStep}) then
                      return ${toLua lhs}
                    end
                  end
                '';
            desc = "Scroll LSP window up ${scrollStep}";
          }
          rec {
            lhs = "<C-b>";
            rhs =
              mkLuaInline
                # lua
                ''
                  function()
                    if not require('noice').scroll(-${scrollStep}) then
                      return ${toLua lhs}
                    end
                  end
                '';
            desc = "Scroll LSP window down ${scrollStep}";
          }
        ])
        ++ [
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

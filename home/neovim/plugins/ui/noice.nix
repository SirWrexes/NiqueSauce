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

      opts = { };

      keys =
        let
          setMode = mode: map (key: key // { mode = mode; });
          scrollStep = "4";
        in
        (setMode
          [ "n" "i" "s" ]
          [
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
              expr = true;
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
              expr = true;
            }
          ]
        )
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

{ lib, pkgs', ... }:

let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.attrsets) mapAttrs;

  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = [
    {
      package = pkgs'.vimPlugins.colorful-winsep-nvim;

      event = "WinLeave";

      opts = {
        only_line_seq = false;
        symbols = [
          "─"
          "│"
          "╭"
          "╮"
          "╰"
          "╯"
        ];
        hi =
          mapAttrs
            (
              k: v:
              mkLuaInline
                # lua
                ''
                  vim.api.nvim_get_hl(0, { name = ${toLua v} }).${k}
                ''
            )
            {
              fg = "Comment";
              bg = "Comment";
            };
      };
    }
  ];
}

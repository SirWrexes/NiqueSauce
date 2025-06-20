{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-surround;

      keys = [
        "ys"
        "ds"
        "cs"
        {
          # Explicitly tell modes here to ensure it starts on using S in visual mode
          lhs = "S";
          mode = [
            "n"
            "x"
          ];
        }
      ];

      init = mkLuaInline ''function() vim.keymap.del({"n"}, "S") end'';

      config = true;
    }
  ];
}

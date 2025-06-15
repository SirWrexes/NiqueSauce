{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = scope-nvim;

      init = mkLuaInline ''
        function()
          vim.opt.sessionoptions = {
            "buffers",
            "tabpages",
            "globals",
          }
        end
      '';

      config = true;
    }
  ];
}

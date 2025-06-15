{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = ssr;

      keys =
        let
          ssr = cmd: mkLuaInline ''function() require("ssr").${cmd}() end'';
        in
        [
          {
            lhs = "<leader>h";
            rhs = ssr "open";
            desc = "Start";
            mode = [
              "v"
              "n"
            ];
          }
        ];
    }
  ];
}

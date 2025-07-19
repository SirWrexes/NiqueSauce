{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline toLua;
  toLua' = toLua { multiline = false; };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = actions-preview-nvim;

      dependencies = [ { package = snacks-nvim; } ];

      opts = {
        diff = {
          algorithm = "patience";
          ignore_whitespace = true;
        };
        backends = [ "snacks" ];
      };

      keys =
        let
          actions' =
            opts:
            mkLuaInline
              # lua
              ''
                function()
                  require("actions-preview").code_actions(${toLua' opts})
                end
              '';

          actions = actions' null;

          mode = [
            "n"
            "x"
          ];
        in
        map (key: key // { inherit mode; }) [
          {
            lhs = "<leader>a";
            rhs = actions;
            desc = "Current line";
          }
          {
            lhs = "<leader>A";
            rhs = actions' { context.only = "source"; };
            desc = "Current buffer";
          }
        ];
    }
  ];
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  inherit (config.programs.neovim.lazy-nvim) toLua;
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
          actions' = opts: ''
            <Cmd>lua require("actions-preview").code_actions(${if opts != null then toLua opts else ""})<Cr>
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

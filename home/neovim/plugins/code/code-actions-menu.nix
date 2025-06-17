{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = actions-preview-nvim;

      dependencies = [ { package = telescope-nvim; } ];

      opts = {
        diff = {
          algorithm = "patience";
          ignore_whitespace = true;
        };
        telescope = {
          winblen = 10;
          sorting_strategy = "ascending";
          layout_strategy = "vertical";
          layout_config = {
            width = 0.8;
            height = 0.9;
            prompt_position = "top";
            preview_cutoff = 20;
            preview_height = mkLuaInline ''function(_,_, maxln) return maxln - 15 end'';
          };
        };
      };

      config = mkLuaInline ''
        function(_, opts)
          opts.telescope = require("telescope.themes").get_dropdown(opts.telescope)
          require("actions-preview").setup(opts)
        end
      '';

      keys =
        let
          actions = ''require("actions-preview").code_actions'';
          mode = [
            "n"
            "x"
          ];
        in
        [
          {
            lhs = "<leader>a";
            rhs = mkLuaInline ''function() ${actions}() end'';
            desc = "Code actions for current line";
            inherit mode;
          }
          {
            lhs = "<leader>A";
            rhs = mkLuaInline ''function() ${actions}({context = {only = "source"}}) end'';
            desc = "Code actions for current buffer";
            inherit mode;
          }
        ];
    }
  ];
}

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
      package = comment-nvim;

      dependencies = [ { package = nvim-ts-context-commentstring; } ];

      # Disable default mappins
      opts = {
        toggler = {
          line = null;
          block = null;
        };
        opleader = {
          line = null;
          block = null;
        };
        extra = {
          line = null;
          block = null;
        };

        padding = true;
        sticky = true;

        pre_hok = mkLuaInline ''function() return vim.bo.commentstring end'';
      };

      config =
        let
          inherit (config.programs.neovim.lazy-nvim) toLua;
          # [[filetype commentPrefix]]
          # Lis of filetype and comment prefix pairs
          #   The command prefix represents the character(s) needed to mark a line as comment.
          #   It should contain %s somewhere to indicate where to place the cursor.
          custom = [
            [
              "hyprlang"
              "# %s"
            ]
          ];
        in
        mkLuaInline ''
          function(_, opts)
            local ft = require "Comment.ft"

            vim.tbl_map(function(cs) ft[cs[1]] = cs[2] end, ${toLua custom})
            require("Comment").setup(opts)
          end
        '';

      keys =
        let
          feedKeys = ''
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
              "nx",
              false
            )
          '';
          normal = fnContent: mkLuaInline ''function() ${fnContent} end'';
          visual = fnContent: (normal ("${feedKeys} ${fnContent}"));

          toggle = cmd: param: ''require("Comment.api").toggle.${cmd}(${param})'';
          visualParam = "vim.fn.visualmode()";
        in
        [
          {
            lhs = "<C-/>";
            rhs = normal (toggle "linewise.current" "");
            mode = [
              "i"
              "n"
            ];
            desc = "Toggle as line";
          }
          {
            lhs = "<C-S-/>";
            rhs = normal (toggle "blockwise.current" "");
            mode = [
              "i"
              "n"
            ];
            desc = "Toggle as block";
          }
          {
            lhs = "<C-/>";
            rhs = visual (toggle "linewise" visualParam);
            mode = "x";
            desc = "Toggle selection (as lines)";
          }
          {
            lhs = "<C-S-/>";
            rhs = visual (toggle "blockwise" visualParam);
            mode = "x";
            desc = "Toggle selectin (as block)";
          }
        ];
    }
  ];
}

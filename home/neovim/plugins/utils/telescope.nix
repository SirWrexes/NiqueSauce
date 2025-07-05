{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.trivial) flip;
in
{
  programs.neovim.extraPackages = with pkgs; [
    fd
    ripgrep
  ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = telescope-nvim;

      dependencies = [
        { package = plenary-nvim; }
        { package = telescope-fzf-native-nvim; }
        { package = telescope-emoji-nvim; }
        { package = scope-nvim; }
      ];

      opts = {
        pickers.colorscheme = {
          theme = "dropdown";
          enable_preview = true;
        };
      };

      config =
        mkLuaInline
          # lua
          ''
            function(_, opts)
              local tele = require "telescope"
              tele.setup(opts)
              tele.load_extension "fzf"
              tele.load_extension "scope"
            end
          '';

      keys =
        let
          inherit (config.programs.neovim.lazy-nvim) toLua;

          tele' =
            cmd: opts:
            mkLuaInline
              # lua
              ''
                function() require("telescope.builtin").${cmd}(${toLua opts}) end
              '';

          tele = flip tele' { };

          ext =
            cmd:
            mkLuaInline
              # lua
              ''
                require("telescope").extensions.${cmd}
              '';

          mkKeys = map (
            mapping:
            mapping
            // {
              mode = [
                "n"
                "x"
              ];
            }
          );
        in
        mkKeys [
          {
            lhs = "<leader>fcs";
            rhs = tele "colorscheme";
            desc = "Colorschemes";
          }
          {
            lhs = "<leader>ff";
            rhs = tele "find_files";
            desc = "File picker";
          }
          {
            lhs = "<leader>fg";
            rhs = tele "live_grep";
            desc = "Live grep";
          }
          {
            lhs = "<leader>fb";
            rhs = tele "buffers";
            desc = "Buffer picker";
          }
          {
            lhs = "<leader>fqf";
            rhs = tele "quickfix";
            desc = "Quickfix list";
          }
          {
            lhs = "<leader>fts";
            rhs = tele "treesitter";
            desc = "TreeSitter tags";
          }
          {
            lhs = "<leader>fd";
            rhs = tele' "diagnostics" { bufnr = 0; };
            desc = "Diagnostics";
          }
          {
            lhs = "<leader>fD";
            rhs = tele "diagnostics";
            desc = "Diagnostics (all buffers)";
          }
          {
            lhs = "gr";
            rhs = tele "lsp_references";
            desc = "LSP references";
          }
          {
            lhs = "gd";
            rhs = tele "lsp_definitions";
            desc = "LSP definitions";
          }
          {
            lhs = "gt";
            rhs = tele "lsp_type_definitions";
            desc = "LSP type definition";
          }
          {
            lhs = "gi";
            rhs = tele "lsp_implementations";
            desc = "LSP implementations";
          }
        ];
    }
  ];
}

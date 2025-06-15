{ pkgs, lib, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = barbar-nvim;

      dependencies = [
        { package = gitsigns-nvim; }
        { package = nvim-web-devicons; }
      ];

      init = ./init.lua;

      opts = {
        auto_hide = true;
        exclude_ft = [ "NvimTree" ];
        hide.extensions = true;
        semantic_letters = true;
        sidebar_filetypes = {
          NvimTree = true;
          undotree.text = "undotree";
        };
      };

      keys =
        let
          inherit (lib.attrsets) updateManyAttrsByPath;
          inherit (builtins) genList;
          mkKeys = map (updateManyAttrsByPath [
            {
              path = [ "mode" ];
              update = _: [
                "i"
                "n"
                "x"
              ];
            }
            {
              path = [ "noremap" ];
              update = _: true;
            }
            {
              path = [ "rhs" ];
              update = cmd: "<cmd>${cmd}<cr>";
            }
          ]);
        in
        mkKeys [
          {
            lhs = "<S-PageUp>";
            rhs = "BufferPrevious";
            desc = "Move to previous buffer";
          }
          {
            lhs = "<S-PageDown>";
            rhs = "BufferNext";
            desc = "Move to next buffer";
          }
          {
            lhs = "<C-,>";
            rhs = "BufferMovePrevious";
            desc = "Move buffer tab left";
          }
          {
            lhs = "<C-.>";
            rhs = "BufferMoveNext";
            desc = "Move buffer tab right";
          }
          {
            lhs = "<leader>bc";
            rhs = "BufferClose";
            desc = "Close current buffer";
          }
          {
            lhs = "<leader>bC";
            rhs = "BufferCloserAllButCurrent";
            desc = "Close all buffers except current";
          }
          {
            lhs = "<leader>bx";
            rhs = "up | BufferClose";
            desc = "Save changes and close buffer";
          }
          {
            lhs = "<leader>bd";
            rhs = "BufferClose!";
            desc = "Close buffer without saving";
          }
          {
            lhs = "<leader>bp";
            rhs = "BufferPick";
            desc = "Open buffer picker";
          }
          {
            lhs = "<leader>bm";
            desc = "Move buffer to tab";
          }
          {
            lhs = "<leader>bon";
            rhs = "BufferOrderByNumber";
            desc = "Order buffers by number";
          }
          {
            lhs = "<leader>bod";
            rhs = "BufferOrderByDirectory";
            desc = "Order buffers by directory";
          }
          {
            lhs = "<leader>bol";
            rhs = "BufferOrderByLanguage";
            desc = "Order buffers by language";
          }
          {
            lhs = "<leader>bow";
            rhs = "BufferOrderByWindowNumber";
            desc = "Order buffers by window number";
          }
          {
            lhs = "<C-0>";
            rhs = "BufferLast";
            desc = "Jump to buffer in last position";
          }
        ]
        ++ (genList (
          x:
          let
            n = x + 1;
          in
          {
            lhs = "<C-${n}>";
            rhs = "BufferGoto ${toString n}";
            desc = "Jump to buffer ${toString n}";
          }
        ) 8);
    }
  ];
}

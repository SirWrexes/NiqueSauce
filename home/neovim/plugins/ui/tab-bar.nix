{ pkgs, lib, ... }:

let
  inherit (builtins) concatLists genList;
  inherit (lib.generators) mkLuaInline;
  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = bufferline-nvim;

      dependencies = [
        { package = nvim-web-devicons; }
        { package = snacks-nvim; }
      ];

      event = [
        "BufNew"
        "BufWinEnter"
      ];

      opts.options = {
        separator_style = "slope";
        hover = {
          enabled = true;
          delay = 200;
          reveal = [ "close" ];
        };
        close_command = mkLuaInline ''function(n) Snacks.bufdelete(n) end'';
        right_mouse_command = mkLuaInline ''function(n) Snacks.bufdelete(n) end'';
        always_show_bufferline = false;
        diagnostics = "nvim_lsp";
        diagnostics_indicator =
          mkLuaInline
            # lua
            ''
              function(_, _, diag)
                local e, w = diag.error, diag.warning
                return (
                  (e and " " .. e) or ""
                ) .. (
                  e and w and " " or ""
                ) .. (
                  (w and " " .. w) or ""
                )
              end
            '';
        offsets = [
          { filetype = "snacks_layout_box"; }
        ];
        get_element_icon =
          mkLuaInline
            # lua
            ''
              function(element)
                return require('nvim-web-devicons')
                  .get_icon_by_filetype(
                    element.filetype,
                    { default = false }
                  )
              end
            '';
      };

      config =
        mkLuaInline
          # lua
          ''
            function(_, opts)
              require('bufferline').setup(opts)
              vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
                callback = function()
                  vim.schedule(function() pcall(nvim_bufferline) end)
                end
              })
            end
          '';

      keys =
        let
          Cmd = cmd: "<Cmd>${cmd}<Cr>";
          mkKeys = map (
            {
              rhs,
              ...
            }@mapping:
            mapping // { rhs = Cmd rhs; }
          );
        in
        mkKeys [
          {
            lhs = "<leader>bd";
            rhs = "lua Snacks.bufdelete()";
            desc = "Delete current buffer";
          }
          {
            lhs = "<leader>bp";
            rhs = "BufferLineTogglePin";
            desc = "Toggle pin";
          }
          {
            lhs = "<leader>bP";
            rhs = "BufferLineGroupClose ungrouped";
            desc = "Delete non-pinned buffers";
          }
          {
            lhs = "<leader>bo";
            rhs = "BufferLineCloseOthers";
            desc = "Delete all but current buffers";
          }
          {
            lhs = "<leader>br";
            rhs = "BufferLineCloseRight";
            desc = "Delete buffers to the right";
          }
          {
            lhs = "<leader>bl";
            rhs = "BufferLineCloseLeft";
            desc = "Delete buffers to the left";
          }
          {
            lhs = "<S-h>";
            rhs = "BufferLineCyclePrev";
            desc = "Previous buffer";
          }
          {
            lhs = "<S-l>";
            rhs = "BufferLineCycleNext";
            desc = "Next buffer";
          }
          {
            lhs = "<M-h>";
            rhs = "BufferLineMovePrev";
            desc = "Move left";
          }
          {
            lhs = "<M-l>";
            rhs = "BufferLineMoveNext";
            desc = "Move right";
          }
        ]
        ++ (genList (
          i:
          let
            tabnr = toString (i + 1);
          in
          {
            lhs = "<M-${tabnr}";
            rhs = "BufferLineGoToBuffer ${tabnr}";
            desc = "Go to tab ${tabnr}";
          }
        ) 8);
    }
  ];
}

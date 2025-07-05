{ pkgs, lib, ... }:

let
  inherit (lib.trivial) pipe;
  inherit (lib.attrsets) mergeAttrsList;
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = conform-nvim;

      event = "BufWritePre";

      init = mkLuaInline ''
        function() vim.o.formatexpr = "v:lua.require('conform').formatexpr()" end
      '';

      opts = {
        formatters_by_ft =
          {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
          }
          // (pipe
            [
              "javascript"
              "typescript"
              "javascriptreact"
              "typescriptreact"
            ]
            [
              (map (ft: {
                ${ft} = [
                  "prettierd"
                  "prettier"
                ];
              }))
              mergeAttrsList
            ]
          );
        format_on_save = {
          lsp_format = "never";
        };
      };

      keys = [
        {
          lhs = "<M-f>";
          rhs = mkLuaInline ''function() require('conform').format() end'';
          desc = "Format buffer";
        }
      ];
    }
  ];
}

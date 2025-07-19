{ pkgs, lib, ... }:

let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe;
in
{
  # TODO: Implement an init that walks up in search of a JS root marker
  #       Then, depending on the package manager in use, check that either
  #       `prettierd` or `prettier` is runnable from local packages
  #       else fall back to globally installed `prettierd`.
  home.packages = with pkgs; [
    prettierd # The cooler prettier

    # Go stuff
    golines # Break long lines automatically
    gci # Import organiser
    gofumpt # Actual formatter, stricter than gofmt
  ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = conform-nvim;

      event = "BufWritePre";

      init = mkLuaInline ''
        function() vim.o.formatexpr = "v:lua.require('conform').formatexpr()" end
      '';

      opts = {
        formatters_by_ft =
          genAttrs
            [
              "css"
              # "html"
              "javascript"
              "javascriptreact"
              "json"
              "jsonc"
              "markdown"
              "scss"
              "typescript"
              "typescriptreact"
              "yaml"
            ]
            (ft: [
              "prettierd"
            ])
          // {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            go = [
              "golines"
              "gci"
              "gofumpt"
            ];
            html = [ "superhtml" ];
          };

        formatters = {
          gofumpt.prepend_args = [ "-extra" ];
          superhtml = {
            command = getExe pkgs.superhtml;
            args = [
              "fmt"
              "--stdin"
            ];
          };
        };

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

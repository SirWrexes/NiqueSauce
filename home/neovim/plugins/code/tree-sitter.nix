{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (lib.generators) mkLuaInline;
  inherit (config.programs.neovim.lazy-nvim) toLua;

  cfg = config.programs.neovim.lazy-nvim.treesitter;
in
{
  options.programs.neovim.lazy-nvim.treesitter.parsers =
    with types;
    mkOption {
      type = functionTo (listOf package);
      default = _: [ ];
      description = "TreeSitter parsers to install";
    };

  config = {
    programs.neovim.extraPackages = with pkgs; [
      clang
      tree-sitter
      stdenv.cc.cc.lib
    ];

    programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
      {
        package = nvim-treesitter;

        dependencies =
          let
            inherit (pkgs.vimPlugins) nvim-treesitter nvim-treesitter-parsers;
            inherit (nvim-treesitter) grammarToPlugin;

            ts-parsers = map grammarToPlugin (cfg.parsers nvim-treesitter-parsers);
            ts-parsers-deps = map (package: { inherit package; }) ts-parsers;
          in
          ts-parsers-deps
          ++ [
            { package = nvim-treesitter-refactor; }
            { package = nvim-treesitter-textobjects; }
            {
              package = nvim-treesitter-context;
              opts = {
                enable = true;
                max_lines = 0;
                separator = "·";
              };
              config = mkLuaInline ''
                function(_, opts)
                  require("treesitter-context").setup(opts)
                  vim.cmd [[hi! link TreeSitterContextSeparator SignColumn]]
                end
              '';
            }
          ];

        main = "nvim-treesitter.configs";

        event = [
          "BufReadPre"
          "BufNewFile"
        ];

        opts = {
          auto_install = false;
          indent.enable = true;
          highlight.enable = true;
          incremental_selection.enable = true;
          textobjects = {
            select.enable = true;
            swap.enable = true;
            lsp_interop = true;
          };
        };

        keys =
          let
            inherit (lib.attrsets) updateManyAttrsByPath;
            peek = context: "<cmd>TSTextobjectPeekDefinitionCode ${context}<cr>";
            mkKeys = map (updateManyAttrsByPath [
              {
                path = [ "mode" ];
                update = _: [
                  "n"
                  "i"
                ];
              }
            ]);
          in
          mkKeys [
            {
              lhs = "<C-p>if";
              rhs = peek "@function.inner";
              desc = "Peek inner function definition";
            }
            {
              lhs = "<C-p>af";
              rhs = peek "@function.outer";
              desc = "Peek outer function definition";
            }
            {
              lhs = "<C-p>ic";
              rhs = "@class.inner";
              desc = "Peek inner class definition";
            }
            {
              lhs = "<C-p>ac";
              rhs = "@class.outer";
              desc = "Peek outer class definition";
            }
          ];
      }
    ];
  };
}

{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
  inherit (pkgs) vimPlugins fet;

  relativity = pkgs.vimUtils.buildVimPlugin {
    name = "vim-relativity";
    src = pkgs.fetchFromGitHub {
      owner = "kennykaye";
      repo = "vim-relativity";
      rev = "64e5215a0915b96c149ecb5b72d2fb68c3a39082";
      hash = "sha256-v4I8SEPGsjvnOxR516Ki72K5jH7U3hgPLW79iO657xc=";
    };
  };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = relativity;

      init =
        mkLuaInline
          # lua
          ''
            function()
              local ignored_fts = {
                "toggleterm",
                "dap-repl",
              }

              vim.o.number = true
              vim.o.relativenumber = true
              vim.g.relativity_enabled_on_start = 1
              vim.g.relativity_focus_toggle = 1
              vim.g.relativity_filetype_ignore = ignored_fts
            end
          '';
    }
    {
      package = gitsigns-nvim;

      opts = {
        numhl = true;
        current_line_blame = true;
      };
    }
  ];
}

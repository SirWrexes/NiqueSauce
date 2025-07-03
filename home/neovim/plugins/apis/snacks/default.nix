{ pkgs, lib, ... }@args:

let
  inherit (builtins) concatStringsSep;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) readFile;
  inherit (lib.trivial) flip pipe;

  readInit = flip pipe [
    (name: ./init + "/${name}.lua")
    readFile
    (code: ''
      do
      ${code}
      end
    '')
  ];

  inits = map readInit [
    "debug-globals"
    "lsp-progress"
    "nvim-tree-integration"
  ];
in
{
  home.packages = with pkgs; [
    dwt1-shell-color-scripts
    gh
    gh-notify
    git-graph
    lazygit
  ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = snacks-nvim;

      lazy = false;

      priority = 999;

      opts = {
        animate.enabled = true;
        dashboard = import ./configs/dashboard.nix args;
        debug.enabled = true;
        gitbrowse.enable = true;
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        notify.enabled = true;
        quickfile.enabled = true;
        rename.enabled = true;
        scroll.enabled = true;
        win.border = "rounded";
        styles.border = "rounded";
      };

      init = mkLuaInline ''
        function()
          ${concatStringsSep "\n" inits}
        end
      '';
    }
  ];
}

{ pkgs, lib, ... }@args:

let
  inherit (builtins) concatStringsSep;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) readFile;
  inherit (lib.trivial) pipe;

  inits =
    pipe
      [
        (name: ./init + "${name}.lua")
        readFile
        (code: ''
          do
          ${code}
          end
        '')
      ]
      [
        "debug-globals"
        "lsp-progress"
        "nvim-tree-integration"
      ];
in
{
  home.packages = with pkgs; [
    lazygit
    gh
  ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = snacks-nvim;

      lazy = false;

      priority = 999;

      opts = {
        animate.enabled = true;
        dashboard.example = "github";
        debug.enabled = true;
        indent.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        notify.enabled = true;
        quickfile.enabled = true;
        rename.enabled = true;
        scroll.enabled = true;
        win.border = "rounded";
      };

      init = mkLuaInline ''
        function()
          ${concatStringsSep "\n" inits}
        end
      '';
    }
  ];
}

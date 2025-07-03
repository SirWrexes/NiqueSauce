{ pkgs, lib, ... }@args:

let
  inherit (builtins) concatStringsSep;
  inherit (lib.attrsets) mapAttrs mapAttrsToList mergeAttrsList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) concatLists;
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

  snacks =
    pipe
      [ "indent" "dashboard" "notifier" ]
      [
        (map (name: {
          ${name} = import (./configs + "/${name}.nix") args;
        }))
        mergeAttrsList
      ];

  configs = mapAttrs (snack: { config, ... }: config) snacks;

  prefixKeysDesc =
    snack:
    map (
      key:
      key
      // (
        if key ? desc then
          {
            desc = "Snacks.${snack}: ${key.desc}";
          }
        else
          { }
      )
    );

  keys = concatLists (
    mapAttrsToList (
      snack:
      {
        keys ? [ ],
        ...
      }:
      prefixKeysDesc snack keys
    ) snacks
  );
in
{
  home.packages = with pkgs; [
    dwt1-shell-color-scripts
    gh
    gh-notify
    git-graph
    lazygit
  ];

  # TODO: Add `lazygit` and drop lazygit plugin
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = snacks-nvim;

      lazy = false;

      priority = 999;

      opts = configs // {
        animate.enabled = true;
        debug.enabled = true;
        gitbrowse.enable = true;
        input.enabled = true;
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

      inherit keys;
    }
  ];
}

{ pkgs, lib, ... }@args:

let
  inherit (builtins) concatStringsSep;
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs
    mapAttrsToList
    mergeAttrsList
    ;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) concatLists;
  inherit (lib.strings) readFile;
  inherit (lib.trivial) flip pipe;

  stripNulls = filterAttrs (key: value: value != null);

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
    "nvim-tree-integration"
  ];

  snacks =
    pipe
      [
        "indent"
        "dashboard"
      ]
      [
        (map (name: {
          ${name} = import (./configs + "/${name}.nix") args;
        }))
        mergeAttrsList
      ];

  configs = stripNulls (
    mapAttrs (
      snack:
      {
        config ? null,
        ...
      }:
      config
    ) snacks
  );

  styles = stripNulls (
    mapAttrs (
      snack:
      {
        style ? null,
        ...
      }:
      style
    ) snacks
  );

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

      dependencies = [
        {
          package = nvim-notify;
        }
      ];

      lazy = false;

      priority = 999;

      opts = configs // {
        animate.enabled = true;
        debug.enabled = true;
        gitbrowse.enable = true;
        input.enabled = true;
        quickfile.enabled = true;
        rename.enabled = true;
        win.border = "rounded";
        styles = styles // {
          border = "rounded";
        };
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

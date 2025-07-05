{ pkgs, lib, ... }@args:

let
  inherit (builtins) typeOf concatStringsSep;
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

  snacks =
    pipe
      [
        "indent"
        "dashboard"
        "picker"
      ]
      [
        (map (name: {
          ${name} = import (./configs + "/${name}.nix") args;
        }))
        mergeAttrsList
      ];

  readRootInit = flip pipe [
    (name: ./init + "/${name}.lua")
    readFile
  ];

  readRootInits = map readRootInit;

  readSnackInit = init: if typeOf init == "path" then readFile init else init.expr;

  readSnacksInit = flip pipe [
    (filterAttrs (snack: configs: configs ? init))
    (mapAttrsToList (snack: { init, ... }: init))
    (map readSnackInit)
  ];

  wrapInit = code: ''
    do
    ${code}
    end
  '';

  inits = map wrapInit (
    (readRootInits [
      "debug-globals"
    ])
    ++ (readSnacksInit snacks)
  );

  configs = pipe snacks [
    (filterAttrs (snack: configs: configs ? config))
    (mapAttrs (snack: { config, ... }: config))
  ];

  styles = pipe snacks [
    (filterAttrs (snack: configs: configs ? style))
    (mapAttrs (snack: { config, ... }: config))
  ];

  prefixKeysDesc =
    snack:
    map (
      key:
      key
      // (
        if key ? desc then
          {
            desc = "${snack}  ${key.desc}";
          }
        else
          { }
      )
    );

  keys = pipe snacks [
    (filterAttrs (snack: configs: configs ? keys))
    (mapAttrsToList (snack: { keys, ... }: prefixKeysDesc snack keys))
    concatLists
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
        bufdelete.enabled = true;
        debug.enabled = true;
        gitbrowse.enabled = true;
        input.enabled = true;
        layout.enabled = true;
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

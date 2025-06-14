{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline toLua;

  # TODO: Find a way to make this less verbose
  lua = toLua { multiline = config.programs.neovim.lazy-nvim.luaMultiline; };
in
{
  # Since I'm using the lazy-nvim module and managing plugins with
  # NixPkgs, Lazy sees the plugin has a `dir` and skips the build phase.
  # Thus, we need to install Coq's dependencies manually. It's a
  # tradeoff for having confs written entirely in Nix, but I'll take it.
  programs.neovim.extraPython3Packages =
    pypkgs: with pypkgs; [
      pynvim-pp
      pyyaml
      std2
    ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      name = "Coq";
      package = coq_nvim;
      dependencies = [
        { package = coq-artifacts; }
        { package = coq-thirdparty; }
      ];

      event = "InsertEnter";

      init = mkLuaInline ''
        function()
          vim.g.coq_settings = ${
            lua {
              auto_start = "shut-up";
              keymap = {
                jump_to_mark = "<C-l>";
              };
            }
          }
        end
      '';
    }
  ];
}

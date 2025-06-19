{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline;
  inherit (config.programs.neovim.lazy-nvim) toLua;
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
        (import ./luasnip.nix { inherit pkgs lib; })
      ];

      event = "InsertEnter";

      init = mkLuaInline ''
        function()
          vim.g.coq_settings = ${
            toLua {
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

  programs.neovim.lazy-nvim.lspconfig.defaultCapabilities = mkLuaInline ''
    require("coq").lsp_ensure_capabilities().capabilities
  '';
}

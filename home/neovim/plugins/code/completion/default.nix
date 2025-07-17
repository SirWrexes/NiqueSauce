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
      package = coq_nvim;

      dependencies = [
        { package = coq-artifacts; }
        { package = coq-thirdparty; }
        (import ./luasnip.nix { inherit pkgs lib; })
      ];

      event = "InsertEnter";

      init =
        mkLuaInline
          # lua
          ''
            function()
              vim.g.coq_settings = ${
                toLua {
                  auto_start = "shut-up";

                  keymap.jump_to_mark = "<C-l>";

                  # Ignore "missing" snippets
                  # Without this setting, unless you've defined custom Coq
                  # snippets, you'll get a message saying:
                  # ⚠️  No compatible snippets found, try updating `coq.artifacts`
                  clients.snippets.warn = [ "outdated" ];
                }
              }
            end
          '';
    }
  ];

  programs.neovim.lazy-nvim.lspconfig.defaultCapabilities =
    mkLuaInline
      # lua
      ''
        require("coq").lsp_ensure_capabilities().capabilities
      '';
}

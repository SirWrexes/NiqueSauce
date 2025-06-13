{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.types) mkLuaInline;

  toLua = lib.generators.toLua { };
in
{
  programs.neovim.lazy-nvim.plugins = [
    {
      name = "Coq";
      package = pkgs.vimPlugins.coq_nvim;

      build = ":COQdeps";

      event = "InsertEnter";

      init = mkLuaInline ''
        function()
          vim.g.coq_settings = ${
            toLua {
              auto_start = "shut_up";
              keymap = {
                jump_to_mark = "<Tab>";
              };
            }
          }
        end
      '';
    }
  ];
}

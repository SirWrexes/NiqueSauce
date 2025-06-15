{ pkgs, lib, ... }:

let
  inherit (lib.strings) readFile;
  inherit (lib.generators) mkLuaInline;

  shell = "${pkgs.fish}/bin/fish";
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = toggleterm-nvim;

      init = ./init.lua;

      opts = {
        inherit shell;
        open_mapping = "<C-\\>";
        autochdir = true;
        direction = "horizontal";
      };

      keys =
        let
          inherit (lib.attrsets) updateManyAttrsByPath;

          mkKeys = map (updateManyAttrsByPath [
            {
              path = [ "mode" ];
              update = _: [
                "n"
                "v"
                "i"
                "t"
              ];
            }
          ]);

          toggle =
            direction:
            mkLuaInline ''
              function() vim.cmd.ToggleTerm("direction=${direction}") end
            '';
        in
        mkKeys [
          {
            lhs = "<C-\\>";
            desc = "Toggle terminal (supports motions)";
          }
          {
            lhs = "<F11>";
            rhs = toggle "horizontal";
            desc = "Open horizontal";
          }
          {
            lhs = "<S-F11>";
            rhs = toggle "float";
            desc = "Open float";
          }
          {
            lhs = "<C-F11>";
            rhs = mkLuaInline "vim.cmd.TermSelect";
            desc = "Open terminal picker";
          }
        ];
    }
  ];
}

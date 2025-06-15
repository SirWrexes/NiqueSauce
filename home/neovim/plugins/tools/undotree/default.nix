{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = undotree;

      init = ./init.lua;

      keys = [
        {
          lhs = "<leader>u";
          rhs = "<cmd>UndotreeToggle<cr>";
          mode = [
            "n"
            "x"
          ];
          desc = "Toggle";
        }
      ];
    }
  ];
}

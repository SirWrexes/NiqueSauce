{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = undotree;

      init = mkLuaInline ''
        vim.opt.undofile = true
        vim.g.undotree_WindowLayout = 4
      '';

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

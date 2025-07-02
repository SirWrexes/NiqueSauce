{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = undotree;

      init =
        mkLuaInline
          # lua
          ''
            function()
              local undocache = vim.fn.stdpath "config" .. "/.undotree"

              if not vim.loop.fs_stat(undocache) then
                vim.notify("Creating undotree cache at [" .. undocache .. "]")
                vim.fn.mkdir(undocache, "p", tonumber("777", 8))
              else
                assert(
                  vim.fn.isdirectory(undocache),
                  "Cache path " .. undocache .. " is not a directory!"
                )
              end

              vim.opt.undodir = undocache
              vim.opt.undofile = true
              vim.g.undotree_WindowLayout = 4
            end
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

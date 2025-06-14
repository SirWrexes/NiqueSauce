{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib.generators) mkLuaInline toLua;
  lua = toLua { multiline = config.programs.neovim.lazy-nvim.luaMultiline; };
in
{
  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = nvim-tree-lua;

      dependencies = [ { package = nvim-web-devicons; } ];

      init = mkLuaInline ''
        function()
          -- Disable netrw. It's buggy and tends to clash with nvim-tree
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1

          -- Enable full colour palette if it's not already
          vim.opt.termguicolors = 1
        end
      '';

      opts = {
        sort.sorter = "filetype";

        sync_root_with_cwd = true;
        respect_buf_cwd = true;

        view.width = 50;

        renderer.group_empty = true;

        filters.dotfiles = true;

        update_focused_file.enable = true;

        # on_attach = import ./nvim-tree.on_attach.nix
      };

      config = mkLuaInline ''
        local evt = require('nvim-tree.api').events

        evt.subscribe(
          evt.Event.FileCreated,
          function(file) vim.cmd.edit(file.fname) end
        )

        require('nvim-tree').setup(opts)
      '';

      # keys =
      #   let
      #     inherit (lib.attrsets) updateManyAttrsByPath;

      #     mkKeys = map (updateManyAttrsByPath [
      #       # {
      #       #   path = [ "desc" ];
      #       #   update = desc: "NvimTree: ${desc}";
      #       # }
      #       {
      #         path = [ "rhs" ];
      #         update = cmd: mkLuaInline ''function() require("nvim-tree.api").tree.${cmd}() end'';
      #       }
      #       # {
      #       #   path = [ "mode" ];
      #       #   update = _: [
      #       #     "n"
      #       #     "i"
      #       #     "x"
      #       #   ];
      #       # }
      #     ]);
      #   in
      #   [
      #     {
      #       lhs = "<C-n>";
      #       rhs = "toggle";
      #       # desc = "toggle";
      #     }
      #     {
      #       lhs = "<M-n>";
      #       rhs = "focus";
      #       # desc = "focus";
      #     }
      #   ];
    }
  ];
}

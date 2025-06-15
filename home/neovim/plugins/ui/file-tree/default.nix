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
    rec {
      name = "NvimTree";

      package = nvim-tree-lua;

      dependencies = [ { package = nvim-web-devicons; } ];

      init = mkLuaInline ''
        function()
          -- Disable netrw. It's buggy and tends to clash with nvim-tree
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1

          -- Enable full colour palette if it's not already
          vim.opt.termguicolors = true
        end
      '';

      opts = {
        sort.sorter = "filetype";

        sync_root_with_cwd = true;
        respect_buf_cwd = true;

        view.width = 30;

        renderer.group_empty = true;

        filters.dotfiles = true;

        update_focused_file.enable = true;

        # Due to the fact NvimTree uses buffer-local mappings,
        # most key bindings are set in lua in the `on_attach` event handler.
        on_attach = import ./on_attach.nix { inherit lib name; };
      };

      config = mkLuaInline ''
        function(_, opts)
          local evt = require('nvim-tree.api').events

          evt.subscribe(
            evt.Event.FileCreated,
            function(file) vim.cmd.edit(file.fname) end
          )

          require('nvim-tree').setup(opts)
        end
      '';

      keys =
        let
          inherit (lib.attrsets) updateManyAttrsByPath;

          mkKeys = map (
            { rhs, ... }@key:
            updateManyAttrsByPath [
              {
                path = [ "rhs" ];
                update = cmd: mkLuaInline ''function() require("nvim-tree.api").tree.${cmd}() end'';
              }
              {
                path = [ "mode" ];
                update = _: [
                  "n"
                  "i"
                  "x"
                ];
              }
              {
                path = [ "desc" ];
                update = _: rhs;
              }
            ] key
          );
        in
        mkKeys [
          {
            lhs = "<C-n>";
            rhs = "toggle";
            desc = "toggle";
          }
          {
            lhs = "<M-n>";
            rhs = "focus";
            desc = "focus";
          }
        ];
    }
  ];
}

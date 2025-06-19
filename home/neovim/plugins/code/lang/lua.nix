{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim = {
    plugins = with pkgs.vimPlugins; [
      {
        package = lazydev-nvim;

        dependencies = [
          {
            package = pkgs.lua-language-server;

            ft = "lua";

            config = mkLuaInline ''
              function(_, opts)
                require("lspconfig").lua_ls.setup(opts)
              end
            '';
          }
        ];

        ft = "lua";

        opts.library = [
          {
            path = "luvit-meta/lirary";
            words = [
              "vim%.uv"
              "vim%.loop"
            ];
          }
          {
            path = "LazyVim";
            words = [ "LazyVim" ];
          }
        ];
      }

      {
        package = luvit-meta;
        lazy = true;
      }
    ];
  };
}

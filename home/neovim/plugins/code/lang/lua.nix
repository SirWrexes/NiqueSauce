{ pkgs, ... }:

{
  programs.neovim.lazy-nvim.lspconfig.servers.lua_ls = with pkgs; {
    package = lua-language-server;

    dependencies = with vimPlugins; [ { package = lazydev-nvim; } ];

    ft = "lua";

    opts.settings.Lua = {
      hint.enable = true;
      completion.callSnippet = "Replace";
    };
  };

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lazydev-nvim;

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
}

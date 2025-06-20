{ pkgs, ... }:

{
  home.file.defaultStyluaConfig = {
    source = ./stylua.toml;
    target = ".config/.stylua.toml";
  };

  programs.neovim.lazy-nvim.lspconfig.servers.lua_ls = with pkgs; {
    package = lua-language-server;

    ft = "lua";

    opts.settings.Lua = {
      hint.enable = true;
      completion.callSnippet = "Replace";
    };
  };

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lazydev-nvim;

      dependencies = [ { package = pkgs.lua-language-server; } ];

      ft = "lua";

      opts = {
        integrations = {
          cmp = false; # nvim-cmp hater gang lesgoooo
          coq = true; # Coq fucking rocks
        };
        library = [
          {
            path = "$${3rd}/luv/library";
            words = [
              "vim%.uv"
              "vim%.loop"
            ];
          }
          {
            path = "$${3rd}/luassert/library";
            words = [ "assert" ];
          }
          {
            path = "$${3rd}/busted/library";
            words = [ "describe" ];
          }
          {
            path = "LazyVim";
            words = [ "LazyVim" ];
          }
        ];
      };
    }
  ];
}

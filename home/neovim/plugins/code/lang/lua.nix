{ pkgs, lib, ... }:

let
  languageServer = "lua_ls";
in
{
  programs.neovim.lazy-nvim = {
    plugins = with pkgs.vimPlugins; [
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
            words = ["LazyVim"];
          }
        ];
      }
      {
        package = luvit-meta;
        lazy = true;
      }
    ];

    treesitter.parsers = tsparsers: with tsparsers; [ lua ];

    mason.ensureInstalled = [ languageServer ];
    mason.handlers.${languageServer} = {
      settings.Lua = {
        hint.enable = true;
        completion.callSnippet = "Replace";
      };
    };
  };
}

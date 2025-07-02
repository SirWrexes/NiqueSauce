{ pkgs, ... }:

{
  home.file.defaultStyluaConfig = {
    source = ./stylua.toml;
    target = ".config/stylua/stylua.toml";
  };

  home.packages = with pkgs; [
    lua-language-server
    stylua
  ];

  programs.neovim.lazy-nvim.lspconfig.servers.luals = {
    cmd = [ "lua-language-server" ];
    filetypes = [ "lua" ];
    settings.Lua = {
      hint.enable = true;
      completion.callSnippet = "Replace";
    };
  };

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lazydev-nvim;

      ft = "lua";

      opts = {
        integrations = {
          cmp = false; # nvim-cmp hater gang lesgoooo
          coq = true; # Coq fucking rocks
        };
        library = [
          {
            path = "\${3rd}/luv/library";
            words = [
              "vim%.uv"
              "vim%.loop"
            ];
          }
          {
            path = "\${3rd}/luassert/library";
            words = [ "assert" ];
          }
          {
            path = "\${3rd}/busted/library";
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

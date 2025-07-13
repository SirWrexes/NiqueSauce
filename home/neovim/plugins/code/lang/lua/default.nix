{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  server = pkgs.lua-language-server;
  exe = lib.meta.getExe server;
in
{
  home.file.defaultStyluaConfig = {
    source = ./stylua.toml;
    target = ".config/stylua/stylua.toml";
  };

  home.packages = with pkgs; [
    server
    stylua
  ];

  programs.neovim.lazy-nvim.lspconfig.servers.luals = {
    cmd = [ exe ];
    filetypes = [ "lua" ];
    root_markers = [
      [
        ".luarc.json"
        ".luarc.jsonc"
      ]
      "git"
    ];
    root_dir =
      mkLuaInline
        # lua
        ''
          function(bufnr, on_dir)
            return on_dir(require('lazydev').find_workspace(bufnr))
          end
        '';
    settings.Lua = {
      hint.enable = true;
      completion.callSnippet = "Replace";
    };
  };

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lazydev-nvim;

      lazy = true;

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

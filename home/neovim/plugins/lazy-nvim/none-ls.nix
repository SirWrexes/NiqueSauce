{
  config,
  pkgs,
  lib,
  ...
}:

let
  lazylib = import ./lib { inherit lib; };

  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkOption;
  inherit (lazylib) types toLua;

  cfg = config.programs.neovim.lazy-nvim.none-ls;

  extras = pkgs.vimUtils.buildVimPlugin {
    name = "none-ls-extras-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "nvimtools";
      repo = "none-ls-extras.nvim";
      rev = "924fe88a9983c7d90dbb31fc4e3129a583ea0a90";
      hash = "sha256-OJHg2+h3zvlK7LJ8kY6f7et0w6emnxfcDbjD1YyWRTw=";
    };
    doCheck = false;
  };
in
{
  options.programs.neovim.lazy-nvim.none-ls = {
    sources =
      with types;
      mkOption {
        type = nullOr (listOf luaSnippet);
        default = null;
      };
  };

  config = lib.mkIf config.programs.neovim.lazy-nvim.enable {
    programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
      {
        package = none-ls-nvim;

        dependencies = [
          { package = plenary-nvim; }
          { package = extras; }
        ];

        event = "VeryLazy";

        opts = mkLuaInline
          ''
            function()
              return { sources = ${toLua cfg.sources} }
            end
          '';
      }
    ];
  };
}

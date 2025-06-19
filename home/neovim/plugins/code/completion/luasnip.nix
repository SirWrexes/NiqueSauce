{ pkgs, lib, ... }:

let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.generators) mkLuaInline;

  toLua = lib.generators.toLua { };

  mireq-snippets = pkgs.vimUtils.buildVimPlugin {
    name = "mireq-luasnip-snippets";
    src = pkgs.fetchFromGitHub {
      owner = "mireq";
      repo = "luasnip-snippets";
      rev = "e871a7257c64a07d620a317b2c051a2cbc69cf7b";
      hash = "sha256-uDOLobhRNcAQCEpJ8N2knxWZ4Y4a9WLph+bY9qvVago=";
    };
    # By default, Nix will try to do require checks for Vim plugins.
    # Howver, this plugin does a lot of requiring luasnip, which isn't available during install.
    doCheck = false;
  };

  sniputils = "luasnip_snippets.common.snip_utils";
in
with pkgs.vimPlugins;
{
  package = luasnip;

  dependencies = [
    { package = friendly-snippets; }
    { package = LuaSnip-snippets-nvim; }
    {
      package = mireq-snippets;
      main = sniputils;
    }
  ];

  opts = {
    keep_roots = true;
    link_roots = true;
    link_children = true;
    enable_autosnippets = true;
    update_events = [
      "TextChanged"
      "TextChangedI"
    ];
    delete_check_events = [ "TextChanged" ];
  };

  config =
    let
      loadFrom' = source: ''require("luasnip.loaders.from_${source}").lazy_load()'';
      loadFrom = sources: concatStringsSep "\n" (map loadFrom' sources);
    in
    mkLuaInline ''
      function(_, opts)
        local utils = require ${toLua sniputils}
        local luasnip = require "luasnip"

        opts.load_ft = utils.load_ft_func
        opts.ft_func = utils.ft_func

        luasnip.setup(opts)

        ${loadFrom [
          "vscode"
          "snipmate"
          "lua"
        ]}
      end
    '';
}

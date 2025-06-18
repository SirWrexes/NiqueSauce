{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.lazy-nvim = {
    plugins = with pkgs.vimPlugins; [
      {
        package = SchemaStore-nvim;
        lazy = true;
      }
    ];

    mason.handlers.yamlls.settings.yaml = {
      schemaStore = {
        # Contrintuitively, the builtin must be *disabled* for advanced use of the plugin
        enable = false;
        url = "";
      };
      schemas = mkLuaInline ''require("schemastore").yaml.schemas()'';
    };
  };
}

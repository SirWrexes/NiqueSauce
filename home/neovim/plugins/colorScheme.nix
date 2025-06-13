{
  config,
  pkgs,
  nix-colors,
  ...
}:

let
  inherit (config.colorScheme) palette slug;
  contrib = nix-colors.lib.contrib { inherit pkgs; };
in
{
  # TODO: Make this into a usable plugin for Lazy
  programs.neovim.plugins = [
    {
      plugin = contrib.vimThemeFromScheme { scheme = palette; };
      config = "colorscheme nix-${slug}";
    }
  ];
}

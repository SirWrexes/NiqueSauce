{
  config,
  pkgs,
  nix-colors,
  ...
}:

let
  contrib = nix-colors.lib.contrib { inherit pkgs; };
  scheme = config.colorScheme;
in
{
  plugin = contrib.vimThemeFromScheme { inherit scheme; };
  config = "colorscheme nix-${scheme.slug}";
}

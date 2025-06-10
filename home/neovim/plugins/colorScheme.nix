{ scheme, nix-colors }:

{
  plugin = nix-colors.wimThemeFromScheme { inherit scheme; };
  config = "colorscheme nix-${scheme.slug}";
}

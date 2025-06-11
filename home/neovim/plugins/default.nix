{
  config,
  pkgs,
  nix-colors,
  ...
}@inputs:

{
  programs.neovim.plugins = map (plugin: import plugin inputs) [ ./colorScheme.nix ];
}

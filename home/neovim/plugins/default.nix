{
  config,
  pkgs,
  nix-colors,
  ...
}@inputs:

{
  programs.neovim.plugins = builtins.map (plugin: import plugin inputs) [ ./colorScheme.nix ];
}

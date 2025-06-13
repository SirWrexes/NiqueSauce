{
  config,
  pkgs,
  nix-colors,
  ...
}:

let
  username = "wrexes";
  sessionVariables = import ./env { inherit pkgs; };
in
{
  imports = [
    nix-colors.homeManagerModules.default

    # CLI
    ./shell
    ./git
    ./neovim

    # GUI
    ./hyprland
    ./discord.nix
    ./browser
  ];

  programs.home-manager.enable = true;

  # Credi: Fahrenheit by fcpg
  # https://github.com/fcpg/vim-fahrenheit
  colorScheme = {
    slug = "vim-fahrenheit";
    name = "Fahrenheit";
    author = "github.com/fcpg";
    palette = {
      base00 = "#ffffff";
      base01 = "#ffffd7";
      base02 = "#ffd7af";
      base03 = "#d7af87";
      base04 = "#af875f";
      base05 = "#d7875f";
      base06 = "#ffaf5f";
      base07 = "#ffd787";
      base08 = "#ffd75f";
      base09 = "#d75f00";
      base0A = "#870000";
      base0B = "#875f5f";
      base0C = "#5f87af";
      base0D = "#a8a8a8";
      base0E = "#262626";
      base0F = "#000000";
    };
  };

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = sessionVariables.unix;

    packages = with pkgs; [
      wl-clipboard
      wev
    ];
  };

  programs.nh = {
    enable = true;
    flake = "$HOME/.nixos";
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # DON'T TOUCH THAT
  home.stateVersion = "25.05";
}

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
  colorScheme = nix-colors.colorSchemes.black-metal-bathory;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = sessionVariables.unix;

    packages = with pkgs; [
      # Clipboard backend
      wl-clipboard

      # Live input data visualiser
      wev

      # Screenshot tool
      grimblast

      # Print formatted markdown in terminal
      glow
    ];
  };

  programs = {
    # nixos-rebuild wrapper
    nh = {
      enable = true;
      flake = "$HOME/.nixos";
    };

    # Media downloader
    yt-dlp.enable = true;

    # The best media player
    mpv.enable = true;
  };

  services = {
    # Screenshot tool
    flameshot.enable = true;

    # Clipboard history manager
    cliphist = {
      enable = true;
      allowImages = true;
    };
  };

  # DON'T TOUCH THAT
  home.stateVersion = "25.05";
}

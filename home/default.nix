{
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

    ./shell
    ./git
    ./neovim
    ./hyprland
    ./discord.nix
    ./browser
    ./media
  ];

  programs.home-manager.enable = true;

  colorScheme = nix-colors.colorSchemes.black-metal-bathory;

  home = {
    inherit username;
    homeDirectory = "/home/${username}";

    sessionVariables = sessionVariables.unix;

    packages = with pkgs; [
      # GNU Make
      gnumake

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

    # CLI task manager
    btop.enable = true;
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

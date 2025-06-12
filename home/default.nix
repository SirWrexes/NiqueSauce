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
  ];

  programs.home-manager.enable = true;

  colorScheme = nix-colors.colorSchemes.black-metal-bathory;

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

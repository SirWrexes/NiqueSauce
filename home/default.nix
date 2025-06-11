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

    packages = with pkgs; [ wl-clipboard ];
  };

  programs.nh = {
    enable = true;
    flake = ./flake.nix;
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # Restart services on build
  systemd.user.startServices = "sd-switch";

  # DON'T TOUCH THAT
  home.stateVersion = "25.05";
}

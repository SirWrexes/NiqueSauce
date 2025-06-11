{
  config,
  pkgs,
  nix-colors,
  ...
}:

{
  imports = [
    nix-colors.homeManagerModules.default

    # System
    ./env.nix

    # CLI
    ./shell
    ./git
    ./neovim

    # GUI
    ./hyprland
    ./discord.nix
  ];

  home =
    let
      name = "wrexes";
    in
    {
      username = "${name}";
      homeDirectory = "/home/${name}";
      stateVersion = "25.05";
    };

  colorScheme = nix-colors.colorSchemes.black-metal-bathory;

  # Restart services on build
  systemd.user.startServices = "sd-switch";
}

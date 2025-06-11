{
  config,
  pkgs,
  nix-colors,
  ...
}:

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

  colorScheme = nix-colors.colorSchemes.black-metal-bathory;

  home =
    let
      name = "wrexes";
    in
    {
      username = "${name}";
      homeDirectory = "/home/${name}";
      stateVersion = "25.05"; # Don't touch that
      packages = with pkgs; [ wl-clipboard ];
    };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # Restart services on build
  systemd.user.startServices = "sd-switch";
}

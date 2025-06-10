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

  colorScheme =
    let
      contrib = nix-colors.lib.contrib { inherit pkgs; };
    in
    contrib.colorSchemeFromPicture {
      path = ./color-scheme-image.jpg;
      variant = "dark";
    };

  programs.git = {
    enable = true;
    userName = "Sir Wrexes";
    userEmail = "ludofernandez@msn.com";
    extraConfig = {
      init.defaultBranch = "main";
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
    };
  };

  # Restart services on build
  systemd.user.startServices = "sd-switch";
}

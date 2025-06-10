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

  programs.git =
    let
      keyPath = builtins.getEnv "PRIVATE_SSH_KEY";
      keySetting =
        if keyPath != "" then
          {
            core.sshCommand = "ssh -i ${keyPath}";
          }
        else
          { };
    in
    {
      enable = true;
      userName = "Sir Wrexes";
      userEmail = "ludofernandez@msn.com";
      extraConfig = {
        init.defaultBranch = "main";
      };
    }
    // keySetting;

  # Restart services on build
  systemd.user.startServices = "sd-switch";
}

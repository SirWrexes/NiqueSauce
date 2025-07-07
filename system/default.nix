{
  pkgs,
  ...
}:

{
  imports = [
    ./hosts

    ./boot.nix
    ./locale.nix
    ./shell.nix
    # ./services
    ./networking.nix
    ./graphics.nix
    ./desktop.nix
    ./gaming.nix
  ];

  nix.settings.download-buffer-size = 5242880000;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_stable;

  fonts = {
    fontconfig.useEmbeddedBitmaps = true;
    packages =
      with pkgs;
      let
        nerd-fonts' = builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);
      in
      [
        noto-fonts-emoji
        noto-fonts-cjk-sans
      ]
      ++ nerd-fonts';
  };

  # Configure console keymap
  console =
    with pkgs;
    let
      fira = nerd-fonts.fira-code;
    in
    {
      font = "${fira}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
      useXkbConfig = true;
      packages = with pkgs; [
        fira
        libxkbcommon
      ];
    };

  ## Printing
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable auto-discovery of network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    jq
    fd
    git
    bat
    ripgrep
    kitty

    ffmpeg-full
    pavucontrol

    nixfmt-rfc-style
  ];

  # Define a user account
  users.users.wrexes = {
    initialPassword = "niquesauce";
    isNormalUser = true;
    description = "Sir Wrexes";
    useDefaultShell = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      # CLI tool for all colour things
      pastel
    ];
  };

  # Virtualisation shenanigans
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  nix-colors,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.download-buffer-size = 5242880000;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    gfxmodeEfi = "auto";
    theme = pkgs.catppuccin-grub;
  };

  # For now, NVidia fails building on 6.15, so I'm pinning 6.14 until it's fixed
  boot.kernelPackages = pkgs.linuxPackages_6_14;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "houston"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  nixpkgs.config.nvidia.acceptLicence = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true; # required
      open = false;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  fonts = {
    fontconfig.useEmbeddedBitmaps = true;
    packages =
      with pkgs;
      [
        noto-fonts-emoji
        noto-fonts-cjk-sans
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts);
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
    options = "compose:sclk";
  };

  # Configure console keymap
  console = {
    font = "FiraCode Nerd Font";
    useXkbConfig = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      libxkbcommon
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fish needs to be available as a system package since it's used as a login shell
  programs.fish.enable = true;

  # Define a user account
  users.users.wrexes = {
    isNormalUser = true;
    description = "Sir Wrexes";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install firefox.
  programs.firefox.enable = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    jq
    fd
    git
    bat
    ripgrep
    kitty

    pavucontrol
    alsa-utils
    helvum

    nixfmt-rfc-style
  ];

  # The superior editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    viAlias = true;
    vimAlias = true;
    configure.customRC = ''
      set relativenumber
      set expandtab
      set shiftwidth=2
      set tabstop=2
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

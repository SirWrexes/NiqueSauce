{
  config,
  pkgs,
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
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    gfxmodeEfi = "3440x1440";
    theme = pkgs.catppuccin-grub;
  };

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_xanmod_stable;

  # See https://nixos.wiki/wiki/Fish
  # Section: Setting fish as your shell
  users.defaultUserShell = pkgs.bash;
  programs.fish.enable = true;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING}  && "$LOGNAME" = "wrexes" ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "houston";

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

  ## Printing
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable auto-discovery of network printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account
  users.users.wrexes = {
    initialPassword = "sucepute";
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

  programs.steam = {
    enable = true;
    extest.enable = true;
    protontricks.enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Virtualisation shenanigans
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

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
    alsa-utils
    helvum

    nixfmt-rfc-style
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}

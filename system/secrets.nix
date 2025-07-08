{
  config,
  pkgs,
  lib,
  ...
}:

let
  pinentry = pkgs.pinentry-curses;

  user = config.users.users.wrexes;

  password = "nixos/users/wrexes/password";

  sshPath = "/home/wrexes/.ssh/id_ed25519";
  sshConfig = {
    mode = "0400"; # r--|---|---
    owner = user.name;
    group = user.group;
  };
in
{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pinentry;
    settings.pinentry-program = lib.meta.getExe pinentry;
  };

  sops = {
    age.keyFile = "/home/wrexes/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";
    defaultSopsFile = ./../secrets.yaml;
  };

  sops.secrets = {
    ${password}.neededForUsers = true;

    "ssh/private" = {
      path = sshPath;
    } // sshConfig;

    "ssh/public" = {
      path = sshPath + ".pub";
    } // sshConfig;
  };

  # TODO: Uncomment this when I'm sure sops works
  # users.users.wrexes.hashedPasswordFile = config.sops.secrets.${password}.path;
}

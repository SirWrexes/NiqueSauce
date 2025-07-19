{ name, ... }:

{ config, ... }:

{
  hostConfig = { inherit name; };

  environment.variables.NH_FLAKE = "${config.hostConfig.flakeRoot}#nixosConfigurations#${name}";

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
  };
}

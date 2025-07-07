{ name, flake }:

{ ... }:

{
  hostConfig = { inherit name; };

  programs.nh = {
    flake = "${flake}#nixosConfigurations#${name}";
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
  };
}

{ config, ... }:

let
  path = "${config.home.homeDirectory}/.ssh/id_ed25519";
in
{
  sops.secrets."ssh/private".path = path;
  sops.secrets."ssh/public".path = "${path}.pub";
}

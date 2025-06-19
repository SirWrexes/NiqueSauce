{ config, pkgs, ... }:

let
  inherit (pkgs.lib.trivial) importJSON;
in
{
  programs.firefox.enable = true;

  programs.firefox = {
    #    policies = importJSON ./policies;
  };
}

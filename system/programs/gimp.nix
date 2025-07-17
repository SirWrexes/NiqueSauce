{ pkgs, ... }:

{
  # Might add some plugins at some point if I feel like it/need'em
  hostConfig.system.packages.GUI = with pkgs; [ gimp3 ];
}

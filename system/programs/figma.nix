{ pkgs, ... }:

{
  # Graphic design is my passion
  # (no it's definitely not)
  hostConfig.system.packages.GUI = with pkgs; [ figma-linux ];
}

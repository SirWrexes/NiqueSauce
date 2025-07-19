{ pkgs, lib, ... }:

{
  hostConfig.system.packages.GUI = with pkgs; [ kitty ];

  system.userActivationScripts.linkKittyConfig.text =
    # sh
    ''
      dest=$HOME/.config/kitty

      mkdir -p "$dest"
      ln -sf ${./kitty.conf} "$dest/kitty.conf"
    '';
}

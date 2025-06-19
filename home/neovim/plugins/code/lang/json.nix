{ pkgs, lib, ... }:

{
  programs.neovim.configure = {
    customRC = ''
      " here your custom configuration goes!
    '';
    packages.myVimPackage = with pkgs.vimPlugins; {
      # loaded on launch
      start = [ fugitive ];
      # manually loadable by calling `:packadd $plugin-name`
      opt = [ ];
    };
  };
}

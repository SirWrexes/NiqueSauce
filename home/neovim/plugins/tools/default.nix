{ ... }:

# TODO: Rename module into "utils"
{
  imports = [
    ./undotree

    ./auto-pairs.nix
    ./discord-rtp.nix
    ./images-in-markdown.nix
    ./keymap-reminder.nix
    ./lazygit.nix
    ./structural-search-and-replace.nix
    ./surround.nix
    ./toggler.nix
    ./wakatime.nix
  ];
}

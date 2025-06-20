{ ... }:

{
  programs.neovim.lazy-nvim = {
    enable = true;
    # TODO Find how to make this possible
    # transformGeneratedLua = "pretty";
  };

  imports = [
    ./lazy-nvim

    ./apis
    ./code
    ./ui
    ./utils
  ];
}

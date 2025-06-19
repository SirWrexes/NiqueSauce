{ ... }:

{
  programs.neovim.lazy-nvim = {
    enable = true;
    # transformGeneratedLua = "pretty";
  };

  imports = [
    ./lazy-nvim

    ./apis
    ./code
    ./tools
    ./ui
  ];
}

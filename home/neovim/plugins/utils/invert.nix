{ ... }:

{
  programs.neovim.lazy-nvim.plugins = [
    {
      dir = "~/Repos/neovim/invert.nvim";

      opts.custom_inverses = {
        based = "cringe";
      };
    }
  ];
}

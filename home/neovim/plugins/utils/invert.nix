{ ... }:

{
  programs.neovim.lazy-nvim.plugins = [
    {
      dir = "~/Repos/nvim/invert.nvim";

      opts.custom_inverses = {
        based = "cringe";
      };
    }
  ];
}

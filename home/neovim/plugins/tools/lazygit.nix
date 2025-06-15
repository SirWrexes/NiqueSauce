{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;
in
{
  programs.neovim.extraPackages = with pkgs; [ lazygit ];

  programs.neovim.lazy-nvim.plugins = with pkgs.vimPlugins; [
    {
      package = lazygit-nvim;

      dependencies = [ { package = plenary-nvim; } ];

      init = mkLuaInline ''function() vim.g.lazygit_window_use_plenary = 1 end'';

      keys =
        let
          inherit (lib.attrsets) updateManyAttrsByPath;
          mkKeys = map (updateManyAttrsByPath [
            {
              path = [ "mode" ];
              update = _: "n";
            }
            {
              path = [ "rhs" ];
              update = cmd: "<cmd>${cmd}<cr>";
            }
          ]);
        in
        mkKeys [
          {
            lhs = "<leader>gg";
            rhs = "LazyGit";
            desc = "Open pop-up";
          }
          {
            lhs = "<leader>gc";
            rhs = "LazyGitConfig";
            desc = "Open config";
          }
          {
            lhs = "<leader>gf";
            rhs = "LazyGitFilter";
            desc = "Open project commits";
          }
          {
            lhs = "<leader>gb";
            rhs = "LazyGitCurrentFile";
            desc = "Open buffer commits";
          }
        ];
    }
  ];
}

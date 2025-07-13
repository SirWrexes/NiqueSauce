{ pkgs, lib, ... }:

let
  server = pkgs.gopls;
  exe.server = lib.meta.getExe server;

  linter = pkgs.golangci-lint-langserver;
  exe.linter = lib.meta.getExe linter;
in
{
  home.packages = [
    server
    linter
    pkgs.golangci-lint
  ];

  programs.neovim.lazy-nvim.lspconfig.servers = {
    gopls.cmd = [ exe.server ];
    golangci_lint_ls.cmd = [ exe.linter ];
  };

  programs.neovim.extraLuaConfig =
    # lua
    ''

      -- Go's standards is filthy disgusting tabs.
      -- That makes the tab revealer setting I have visually pollute my sources.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("GolangDisableListCharsTab", { clear = true }),
        pattern = { "go", "gomod" },
        callback = function()
          vim.opt_local.listchars:append { tab = "  " }
        end
      })

    '';
}

{ ... }:

{
  imports = [
    ./completion
    ./cursor-context
    ./lang

    ./code-actions-menu.nix
    ./comment.nix
    ./diagnostics.nix
    ./formatting.nix
    ./tree-hopper.nix
    ./tree-sitter.nix
  ];

  programs.neovim.extraLuaConfig =
    # lua
    ''

      vim.keymap.set(
        {'n', 'i'},
        '<M-i>',
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
        end
      );

    '';

  programs.neovim.lazy-nvim.lspconfig.keys = [
    {
      lhs = "<S-k>";
      rhs = "<Cmd>lua vim.lsp.buf.hover()<Cr>";
      desc = "Show LSP hover";
    }
    {
      lhs = "<C-k>";
      rhs = "<Cmd>lua vim.lsp.buf.signature_help()<Cr>";
      desc = "Show signature help";
    }
  ];
}

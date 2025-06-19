{ ... }:

{
  imports = [
    ./completion
    ./cursor-context
    ./lang

    ./code-actions-menu.nix
    ./comment.nix
    ./formatting.nix
    ./tree-hopper.nix
    ./tree-sitter.nix
  ];

  programs.neovim.extraLuaConfig = ''

    vim.keymap.set(
      {'n', 'i'},
      '<M-i>',
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end
    );

  '';
}

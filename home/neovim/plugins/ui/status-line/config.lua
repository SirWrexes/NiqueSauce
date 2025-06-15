-- Only have one statusbar at the bottom
vim.o.laststatus = 3

-- Disable NVim's default ruler (we've got one in our winbar)
vim.o.ruler = false

-- Force it to be empty an empty string by default (otherwise it shows filename and stuff).
-- This will eventually be replaced with useful contextual information by plugins.
vim.o.statusline = [[%{''}]]

-- Detailed explanation:
--    %n — Buffer number - you never know when you're gonna need them, but when you do you'll be happy they're there !
--    %= — Padding (next items are centered)
--    %f — Relative filename or as provided in the edit command
--    %m — Modified or unmodifiable flag
--    %= — Padding (next items are right aligned)
vim.o.winbar = [[%n%=%f%m%=L%l/%L:%c (%p%%)]]

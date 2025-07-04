-- Use spaces instead of tabs.
-- I personally think people who prefer tabs are deranged.
vim.o.expandtab = true

-- Default to 1 tab = 2 spaces
vim.o.shiftwidth = 0
vim.o.tabstop = 2

-- Enable auto indent, because devs are lazy as heck. 🤷
vim.o.autoindent = true

-- Disable wrapping lines
vim.o.wrap = false

-- Show whitespaces
--   ~      : trailing
--   |      : Make it obvious when there are filthy in your files
--   arrows : indicate text is going out of buffer on the sides
vim.o.list = true
vim.opt.listchars = {
  nbsp = '_',
  tab = '󰌒 ',
  trail = '~',
  extends = ' ',
  precedes = ' ',
}

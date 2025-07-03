do
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
  local winbar = [[ %n%=%f%m%=L%l/%L:%c (%p%%) ]]

  local winbar_ft = {
    -- Remove the bar completely for these fts
    exclude = {
      'NvimTree',
    },

    -- Don't change the bar for these fts
    ignore = {
      'toggleterm',
    },
  }

  local function assign_winbar()
    local ft = vim.bo.ft

    if vim.tbl_contains(winbar_ft.ignore, ft) then return end
    if vim.tbl_contains(winbar_ft.exclude, ft) then
      vim.wo.winbar = nil
    elseif vim.bo.buftype ~= 'nofile' then
      vim.wo.winbar = winbar
    end
  end

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('WinbarExcludeFt', {}),
    callback = assign_winbar,
  })
end

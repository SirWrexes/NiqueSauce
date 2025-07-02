local function set_debug_globals()
  _G.dd = Snacks.debug.inspect
  _G.bt = Snacks.debug.backtrace
  vim.print = _G.dd
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = set_debug_globals,
})

local prev = {} -- Prevents duplicate events

local function on_rename(data)
  if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
    prev = data
    Snacks.rename.on_rename_file(data.old_name, data.new_name)
  end
end

local function subscribe_to_file_rename()
  local ev = require('nvim-tree.api').events
  ev.subscribe(ev.Event.NodeRenamed, on_rename)
end

vim.api.nvim_create_autocmd('User', {
  pattern = 'NvimTreeSetup',
  callback = subscribe_to_file_rename,
})

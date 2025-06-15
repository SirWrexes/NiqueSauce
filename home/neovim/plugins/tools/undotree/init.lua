function()
  local undocache = vim.fn.stdpath "config" .. "/.undotree"

  if not vim.loop.fs_stat(undocache) then
    vim.notify("Creating undotree cache at [" .. undocache .. "]")
    vim.fn.mkdir(undocache, "p", tonumber("777", 8))
  else
    assert(
      vim.fn.isdirectory(undocache),
      "Cache path " .. undocache .. " is not a directory!"
    )
  end

  vim.opt.undodir = undocache
  vim.opt.undofile = true
  vim.g.undotree_WindowLayout = 4
end

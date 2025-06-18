---@type table<string, LspHookFunction>
local hooks = {
  format_on_save = function(client, buffer)
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("FormatOnSave", {}),
        buffer = buffer,
        callback = function()
          _G["PLF_SHOULD_OPEN_PICKER"] = false
          require("plf").format { async = false }
          _G["PLF_SHOULD_OPEN_PICKER"] = true
        end,
      })
    end
  end,

  statusline_context = function(client, buffer)
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, buffer)

      local location = "v:lua.require'nvim-navic'.get_location()"
      local locationlen = string.format("len(%s)", location)

      local fillchars = vim.opt.fillchars:get()
      local filling = fillchars.stl or fillchars.stlnc or "─"
      local fillerlen = string.format("%d - %s", vim.o.columns - 1, locationlen)
      local filler = string.format("repeat('%s', %s)", filling, fillerlen)

      local status = "%#Title#%{%" .. location .. "%}"
      -- Filler disabled for now: See https://github.com/SmiteshP/nvim-navic/issues/148
      -- .. " %#StatusLine#%{"
      -- .. filler
      -- .. "}"

      vim.opt.fillchars:remove { "stl", "stlnc" }
      vim.o.statusline = status
    end
  end,
}

---@type LspHookFunction
function default_on_attach(client, buffer)
  vim
    .iter(pairs(hooks))
    :each(function(_, on_attach) on_attach(client, buffer) end)
end

return default_on_attach

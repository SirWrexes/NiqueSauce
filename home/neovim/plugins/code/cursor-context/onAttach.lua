return function(client, buffer)
  if not client.server_capabilities.documentSymbolProvider then return end

  require("nvim-navic").attach(client, buffer)

  local location = "v:lua.require'nvim-navic'.get_location()"
  local status = "%#Title#%{%" .. location .. "%}"

  vim.opt.fillchars:remove { "stl", "stlnc" }
  vim.o.statusline = status
end

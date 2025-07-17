do
  ---@see Pattern :h pattern
  ---|
  ---@alias FtPattern
  ---| string   # A vim pattern
  ---| string[] # An array of vim patterns

  ---@alias Filetype string # A filetype to assign to files matching given patterns

  ---@alias FtOverride table<FtPattern, Filetype>

  ---@type table<FtOverride>
  local overrides = {
    {
      '*.map',
      'json',
    },
    {
      '*.json',
      'jsonc',
    },
    {
      '\\cdockerfile',
      'dockerfile',
    },
    {
      '.envrc',
      'sh',
    },
  }

  local augroup = vim.api.nvim_create_augroup('FileTypeOverrides', {})

  for _, override in ipairs(overrides) do
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      group = augroup,
      pattern = override[1],
      command = 'set ft=' .. override[2],
    })
  end

  vim.filetype.add {
    extension = {
      ['rasi'] = 'rasi',
      ['htmx'] = 'html',
      ['gohtml'] = 'html',
    },
    pattern = {
      ['.*/hypr/.*%.conf'] = 'hyprlang',
      ['.*/kitty/.*%.conf'] = 'bash',
      ['.*/mako/config'] = 'dosini',
      ['.*/waybar/config'] = 'jsonc',
    },
  }
end

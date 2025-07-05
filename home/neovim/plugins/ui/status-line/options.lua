function()
  -- PERF: we don't need this lualine require madness 🤷
  require('lualine_require').require = require

  vim.o.laststatus = vim.g.lualine_laststatus

  local theme = require 'lualine.themes.auto'
  local BufferLineTab = vim.api.nvim_get_hl(0, { name = "BufferLineTab" })
  local function to_hex(num) return ("%06x"):format(num) end
  local cx = {bg = to_hex(BufferLineTab.bg), fg = to_hex(BufferLineTab.fg)}

  for _, mode in ipairs {
    'normal', 'insert', 'replace', 'visual', 'command'
  } do
    theme[mode].c = { bg = cx.bg, fg = cx.fg }
    theme[mode].x = { bg = cx.bg, fg = cx.fg }
  end

  local opts = {
    options = {
      theme = theme,
      globalstatus = vim.o.laststatus == 3,
      disabled_filetypes = {
        statusline = { 'dashboard', 'snacks_dashboard', 'snacks_layout_box' },
      },
    },
    sections = {
      lualine_a = { 'mode' },

      lualine_b = {
        'branch',
        {
          'diff',
          symbols = {
            added = ' ',
            modified = ' ',
            removed = ' ',
          },
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },

      lualine_c = {
        {
          'filetype',
          icon_only = true,
          separator = '',
          padding = { left = 1, right = 0 },
        },
      },

      lualine_x = {
        Snacks.profiler.status(),
        -- stylua: ignore
        {
          function() return require("noice").api.status.command.get() end,
          cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
          color = function() return { fg = Snacks.util.color("Statement") } end,
        },
        -- stylua: ignore
        {
          function() return "  " .. require("dap").status() end,
          cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
          color = function() return { fg = Snacks.util.color("Debug") } end,
        },
        {
          'diagnostics',
          symbols = {
            error = ' ',
            warn = ' ',
            info = ' ',
            hint = ' ',
          },
        },
      },

      lualine_y = {
        { 'progress', separator = ' ', padding = { left = 1, right = 0 } },
        { 'location', padding = { left = 0, right = 1 } },
      },

      lualine_z = {
        function()
          return ' ' .. os.date '%R'
        end,
      },
    },
    extensions = { 'nvim-tree', 'toggleterm', 'trouble', 'man', 'lazy', 'fzf' },
  }

  -- do not add trouble symbols if aerial is enabled
  -- And allow it to be overriden for some buffer types (see autocmds)
  if vim.g.trouble_lualine then
    local trouble = require 'trouble'
    local symbols = trouble.statusline {
      mode = 'symbols',
      groups = {},
      title = false,
      filter = { range = true },
      format = '{kind_icon}{symbol.name:Normal}',
      hl_group = 'lualine_c_normal',
    }
    table.insert(opts.sections.lualine_c, {
      symbols and symbols.get,
      cond = function()
        return vim.b.trouble_lualine ~= false and symbols.has()
      end,
    })
  end

  return opts
end

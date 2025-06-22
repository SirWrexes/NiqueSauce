do
  ---@alias MapMode
  ---| 'n'
  ---| 'i'
  ---| 'c'
  ---| 'v'
  ---| 'x'
  ---| 'o'
  ---| 's'
  ---| 't'
  ---| 'l'

  ---@alias LHS string

  ---@alias RHS string | function

  ---@class vim.keymap.set.Mapping
  ---@field [1]  MapMode | MapMode[]
  ---@field [2]  LHS
  ---@field [3]  RHS
  ---@field [4]? vim.keymap.set.Opts
  ---@field replaces? LHS

  ---@class vim.keymap.set.Batch
  ---@field [number] vim.keymap.set.Mapping
  ---@field desc_prefix? string

  local function get_prefix_setter(prefix)
    if not prefix then
      return function(mapping)
        -- noop
      end
    end

    ---@param mapping vim.keymap.set.Mapping
    return function(mapping)
      local opts = mapping[4]
      if opts and opts.desc then
        opts.desc = ('%s: %s'):format(prefix, opts.desc)
      end
    end
  end

  ---@param keys vim.keymap.set.Batch
  local function batch(keys)
    local set_prefix = get_prefix_setter(keys.desc_prefix)

    for _, mapping in ipairs(keys) do
      if mapping.replaces then pcall(vim.keymap.del, mapping[1], mapping[2]) end
      set_prefix(mapping)
      vim.keymap.set(unpack(mapping))
    end
  end

  batch {
    desc_prefix = 'Exit NeoVim',
    {
      'n',
      '<C-w>q',
      '<cmd>qa<cr>',
      { desc = 'If all edits are saved' },
    },
    {
      'n',
      '<C-w>x',
      '<cmd>xa!<cr>',
      { desc = 'With saving edits' },
    },
    {
      'n',
      '<C-w>d',
      '<cmd>qa!<cr>',
      { desc = 'Force' },
    },
  }

  batch {
    desc_prefix = 'Save buffer',
    {
      'n',
      '<leader>w',
      '<cmd>up<cr>',
      { desc = 'If has edits' },
    },
    {
      'n',
      '<leader>W',
      '<cmd>w<cr>',
      { desc = 'Force' },
    },
  }

  batch {
    desc_prefix = 'Search',
    {
      'n',
      '<leader><cr>',
      '<cmd>noh<cr>',
      { desc = 'Disable current highlights' },
    },
  }

  batch {
    desc_prefix = 'Vim Tabs',
    {
      'n',
      '<leader>tn',
      '<cmd>tabnew<cr>',
      { desc = 'New' },
    },
    {
      'n',
      '<leader>to',
      '<cmd>tabonly<cr>',
      {
        desc = 'Close current',
      },
    },
    {
      'n',
      '<leader>tc',
      '<cmd>tabclose<cr>',
      { desc = 'Close all but current' },
    },
    { 'n', '<leader>tm', '<cmd>tabmove', { desc = 'Move' } },
    {
      'n',
      '<Leader>tl',
      '<cmd>exe "tabn ".g:lasttab<cr>',
      { desc = 'Go to last accessed' },
    },
    {
      'n',
      '<C-PageUp>',
      '<cmd>tabprevious<cr>',
      { desc = 'Go to previous' },
    },
    { 'n', '<C-PageDown>', '<cmd>tabnext<cr>', { desc = 'Go to next' } },
  }

  batch {
    desc_prefix = 'CWD',
    {
      'n',
      '<leader>cd',
      '<cmd>cd %:p:h<cr>:pwd<cr>',
      { desc = "Set to currently focused buffer's" },
    },
  }

  batch {
    desc_prefix = 'Move lines',
    -- Move lines of text up or down
    {
      'n',
      '<M-k>',
      'mz<cmd>m-2<cr>`z',
      { desc = 'Up' },
    },
    {
      'n',
      '<M-j>',
      'mz<cmd>m+<cr>`z',
      { desc = 'Down' },
    },
    {
      'v',
      '<M-k>',
      ":m'<-2<cr>`>my`<mzgv`yo`z",
      { desc = 'Up' },
    },
    {
      'v',
      '<M-j>',
      ":m'>+<cr>`<my`>mzgv`yo`z",
      { desc = 'Down' },
    },
  }

  batch {
    desc_prefix = 'Sort lines',
    { 'v', '<M-s>', '<cmd>sort<cr>', { desc = 'Alphabetically' } },
  }

  batch {
    desc_prefix = 'Spellcheck',
    {
      'n',
      '<leader>ss',
      '<cmd>setlocal spell!<cr>',
      { desc = 'Toggle on/off' },
    },
    {
      'n',
      '<leader>sn',
      ']s',
      { desc = 'Go to next error' },
    },
    {
      'n',
      '<leader>sp',
      '[s',
      { desc = 'Go to previous error' },
    },
    {
      'n',
      '<leader>sa',
      'zg',
      { desc = "Add current locale's custom dictionary" },
    },
    {
      'n',
      '<leader>s?',
      'z=',
      { desc = 'Show fixes for current error' },
    },
  }

  batch {
    desc_prefix = 'LSP',
    {
      'n',
      '<leader>lrn',
      vim.lsp.buf.rename,
      { desc = 'Rename symbol under cursor' },
      replaces = 'grn',
    },
    {
      'n',
      '<leader>lih',
      function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end,
      { desc = 'Toggle inlay hints on/off' },
    },
  }
end

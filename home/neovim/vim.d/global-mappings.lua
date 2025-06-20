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

  ---@alias LHS string | string[]

  ---@alias RHS string | function

  ---@class vim.keymap.set.Batch
  ---@field [1]  MapMode | MapMode[]
  ---@field [2]  LHS
  ---@field [3]  RHS
  ---@field [4]? vim.keymap.set.Opts

  ---@param keys vim.keymap.set.Batch[]
  local function batch(keys)
    for _, mapping in ipairs(keys) do
      vim.keymap.set(unpack(mapping))
    end
  end

  vim.g.mapleader = ' '

  batch {
    -- How to exit vim
    {
      'n',
      '<C-w>q',
      '<cmd>qa<cr>',
      { desc = 'Exit only no buffer has unsaved changes' },
    },
    { 'n', '<C-w>x', '<cmd>xa!<cr>', { desc = 'Save all changes and exit' } },
    {
      'n',
      '<C-w>d',
      '<cmd>qa!<cr>',
      { desc = 'Exit without saving changes (risky)' },
    },

    -- Fast saving
    {
      'n',
      '<leader>w',
      '<cmd>up<cr>',
      { desc = 'Save current modification (if any)' },
    },
    {
      'n',
      '<leader>W',
      '<cmd>w<cr>',
      { desc = 'Save current buffer (regardless of if changed or not)' },
    },

    -- Disable recent search highlights
    {
      'n',
      '<leader><cr>',
      '<cmd>noh<cr>',
      { desc = 'Disable recent search highlights' },
    },

    -- Manage tabs (not to be confused with windows and buffers)
    { 'n', '<leader>tn', '<cmd>tabnew<cr>', { desc = 'New tab' } },
    { 'n', '<leader>to', '<cmd>tabonly<cr>', { desc = 'Close current tab' } },
    {
      'n',
      '<leader>tc',
      '<cmd>tabclose<cr>',
      { desc = 'Close all but current tab' },
    },
    { 'n', '<leader>tm', '<cmd>tabmove', { desc = 'Move a tab' } },
    {
      'n',
      '<Leader>tl',
      '<cmd>exe "tabn ".g:lasttab<cr>',
      { desc = 'Go to last accessed tab' },
    },
    {
      'n',
      '<C-PageUp>',
      '<cmd>tabprevious<cr>',
      { desc = 'Go to previous tab' },
    },
    { 'n', '<C-PageDown>', '<cmd>tabnext<cr>', { desc = 'Go to next tab' } },

    -- Set CWD to the directory of currently focused buffer
    {
      'n',
      '<leader>cd',
      '<cmd>cd %:p:h<cr>:pwd<cr>',
      { desc = 'Set CWD to the directory of currently focused buffer' },
    },

    -- Move lines of text up or down
    { 'n', '<M-k>', 'mz<cmd>m-2<cr>`z', { desc = 'Move line up' } },
    { 'n', '<M-j>', 'mz<cmd>m+<cr>`z', { desc = 'Move line down' } },
    { 'v', '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z", { desc = 'Move line(s) up' } },
    {
      'v',
      '<M-j>',
      ":m'>+<cr>`<my`>mzgv`yo`z",
      { desc = 'Move line(s) down' },
    },

    -- Sort selection
    { 'v', '<M-s>', ':sort<cr>', { desc = 'Sort lines' } },

    -- Spell checking
    {
      'n',
      '<leader>ss',
      '<cmd>setlocal spell!<cr>',
      { desc = 'Toggle spellcheck on/off' },
    },
    { 'n', '<leader>sn', ']s', { desc = 'Go to next spelling mistake' } },
    { 'n', '<leader>sp', '[s', { desc = 'Go to previous spelling mistake' } },
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
      { desc = 'Show a list of potential fixes for current spelling mistake' },
    },
  }
end

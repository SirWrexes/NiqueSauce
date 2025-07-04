do
  -- Enforce end of line character to follow Unix standard.
  -- Git does this pre-commit by default anyway.
  vim.o.fileformats = 'unix'

  -- Enable loading per-project `.vim/` configs
  -- see https://medium.com/@dnrvs/per-project-settings-in-nvim-fc8c8877d970
  vim.opt.exrc = true
  vim.opt.secure = true

  -- Use a POSIX-compliant shell instead of Fish
  if vim.opt.shell:get() == '' or vim.opt.shell:get():match '.*fish$' then
    local has, path = vim.fn.executable, vim.fn.exepath
    local maybe = function(shell)
      return has(shell) == 1 and path(shell)
    end
    vim.opt.shell = maybe 'zsh' or maybe 'bash' or 'sh'
  end

  -- Command history
  vim.opt.history = 1000

  -- Enable mouse support everywhere possible
  vim.opt.mouse = 'a'

  -- Automatically update a buffer when its file is updated outside of nvim
  vim.opt.autoread = true

  -- Assuming you use version control for sensible files,
  -- disables swap files, auto-backups etc.
  vim.opt.backup = false
  vim.opt.writebackup = false
  vim.opt.swapfile = false

  -- Make auto-buffer switching smarter
  vim.opt.switchbuf = { 'useopen', 'usetab', 'vsplit' }
  vim.opt.showtabline = 2

  -- When opening a file that's already been read, start at last
  -- recorded position.
  vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('SaveCursorPosition', {}),
    callback = function()
      if vim.fn.line [['"]] > 1 and vim.fn.line [['"]] <= vim.fn.line '$' then
        vim.cmd [[normal! g'"]]
      end
    end,
  })

  local hl_TrailingWhiteSpace = 'TrailingWhiteSpace'
  local augroup_TrailingWhiteSpaces =
    vim.api.nvim_create_augroup(hl_TrailingWhiteSpace, { clear = true })

  -- Cleanup trailing whitespaces automatically
  local trailing_ignore = {
    'markdown',
    'gitcommit',
  }

  vim.cmd.match(hl_TrailingWhiteSpace, [[/\s\+$/]])

  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = augroup_TrailingWhiteSpaces,
    callback = function()
      if vim.tbl_contains(trailing_ignore, vim.bo.filetype) then return end
      vim.opt_local.winhighlight:append { [hl_TrailingWhiteSpace] = 'Error' }
    end,
  })

  local function cmd_WhiteSpaceCleanup(opts)
    if not opts.bang and vim.tbl_contains(trailing_ignore, vim.bo.filetype) then
      return
    end

    local pos = vim.fn.getpos '.'
    local reg = vim.fn.getreg '/'
    vim.cmd [[ %s/\s\+$//e ]]

    vim.fn.setpos('.', pos)
    vim.fn.setreg('/', reg)
  end

  vim.api.nvim_create_user_command('WhiteSpaceCleanup', cmd_WhiteSpaceCleanup, {
    bar = true,
    bang = true,
  })

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = augroup_TrailingWhiteSpaces,
    callback = cmd_WhiteSpaceCleanup,
  })

  -- Keep at least 4 lines of content above curor at all times
  vim.opt.scrolloff = 4

  -- Avoid garbled characters in Chinese-configured Windows
  -- ... Though I don't understand Chinese and if you use Windows you're monster anyway.
  vim.env.LANG = 'en'
  vim.opt.langmenu = 'en'

  -- Enable WildMenu
  -- It's the native completion menu for your command line, you want this !
  vim.opt.wildmenu = true

  -- Ignore files in the WildMenu based on patterns
  -- Note: If you start typing out an ignored file, it will still be suggested,
  -- it's a nice way to filter out the noise while still having some good QoL.
  for _, ignore in ipairs {
    '*/.git',
    '*/.hg',
    '*/.svn',
    '*/.DS_Store',
    '*.o',
    '*.pyc',
    '*~',
  } do
    vim.opt.wildignore:append(ignore)
  end

  -- Hide abandonned buffers
  vim.opt.hidden = true

  -- Configure backspace so it acts as it should
  --
  -- ...
  --
  -- Another piece of config I completely forgot what it does.
  -- Judging by the comment, I'm not willing to try without.
  vim.opt.whichwrap = '<,>,h,l'

  -- When searching, first ignore case
  vim.opt.ignorecase = true

  -- Then, actually, be smart about it.
  --
  -- This setting will only work if you have at least 200IQ and watch
  -- Rick and Morty every single day while praying to an altar in
  -- Stephen Hawking's image.
  vim.opt.smartcase = true

  -- Use "magic" syntax for regex by default.
  -- It is STRONGLY advised that you keep this on, see `:h magic`.
  vim.opt.magic = true

  -- When hovering over a bracket or paren, highlight its matching pair.
  vim.opt.showmatch = true
  -- Do it instantly. (This value is in tenths of seconds, for compatibility reasons.)
  vim.opt.matchtime = 0

  -- Disable insufferable error bells
  vim.opt.errorbells = false

  -- Time in miliseconds to wait for a mapping to complete
  -- (e.g. `<leader> ...`)
  --
  -- This is the thing that `nowait` ignores when creating mappings.
  vim.opt.timeoutlen = 750
end

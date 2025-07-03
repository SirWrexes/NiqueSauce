function()
    -- Prevent terminals from getting discarded when put in the background
    vim.o.hidden = true

    vim.api.nvim_create_autocmd("TermOpen", {
      desc = "Set Terminal mode keymaps",
      pattern = "term://*#toggleterm#*",
      group = vim.api.nvim_create_augroup("ToggleTermInit", { clear = true }),
      callback = function()
        vim.wo.winbar = "%= ::" .. vim.b.toggle_number .. "%="

        -- Require a double tap on <esc> to leave terminal mode.
        -- That way, TUIs that rely on <esc> to quit won't make you close the terminal
        -- window when you want out of them.
        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], {
          buffer = 0,
          silent = true,
          noremap = true,
        })
      end,
    })
  end

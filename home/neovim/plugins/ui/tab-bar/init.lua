function()
    vim.g.barbar_auto_setup = false

    vim.opt.sessionoptions:append "globals"
    vim.api.nvim_create_user_command("Mksession", function(attr)
      vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
      vim.cmd.mksession { bang = attr.bang, args = attr.fargs }
    end, {
      bang = true,
      complete = "file",
      desc = "Save barbar with :mksession",
      nargs = "?",
    })
  end

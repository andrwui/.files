local comment = {
  'numToStr/Comment.nvim',

  config = function()
    require('Comment').setup()
    local commentapi = require('Comment.api')
    vim.keymap.set({ 'n' }, '<S-c>', function()
        commentapi.toggle.linewise.current()
      end,
      { noremap = true, silent = true })

    vim.keymap.set({ 'v' }, '<S-c>', function()
        commentapi.toggle.linewise.current(vim.fn.visualmode())
      end,
      { noremap = true, silent = true })
  end
}


return { comment }

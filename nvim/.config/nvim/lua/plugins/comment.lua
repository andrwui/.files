-- comments lines, works like dogshit for blockwise or i'm just fucking stupid which is the most probable cause why this wont work
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
        commentapi.toggle.blockwise.current(vim.fn.visualmode())
      end,
      { noremap = true, silent = true })
  end
}


return { comment }

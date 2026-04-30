local telescope = {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' }
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>bb', builtin.buffers, {})

require('telescope').setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git', '.cache', 'package%-lock%.json' },
  }
})

return { telescope }

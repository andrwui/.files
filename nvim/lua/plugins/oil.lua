local oil = {
  'stevearc/oil.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    vim.keymap.set('n', '<C-b>', '<CMD>Oil<CR>')

    require('oil').setup({
      keymaps = {
        ['<ESC>'] = { 'actions.parent', mode = 'n' }
      }
    })
  end
}

return { oil }

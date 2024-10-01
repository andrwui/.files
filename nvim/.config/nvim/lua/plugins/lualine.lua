local lualine = {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local ll = require('lualine')
      local lc = ll.get_config()
      ll.setup(lc)

    end,
  }

return {lualine}

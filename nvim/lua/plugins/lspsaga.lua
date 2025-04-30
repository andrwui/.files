local lspsaga = {
  'nvimdev/lspsaga.nvim',
  config = function()
    require('lspsaga').setup({
      code_action = {
        num_shortcut = false
      },
      lightbulb = {
        enable = false
      }
    })
  end,
}

return { lspsaga }

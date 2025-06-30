local mv = {
  'OXY2DEV/markview.nvim',
  lazy = false,
  opts = {
    preview = {
      filetypes = {
        "markdown", "codecompanion"
      },
      ignore_buftypes = {},
    },
  },
  config = function()
    require('markview').setup({})
  end
}

return { mv }

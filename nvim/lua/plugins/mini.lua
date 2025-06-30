local move = {
  'echasnovski/mini.move',
  version = '*',
  config = function()
    require('mini.move').setup({

      mappings = {
        left = '<<',
        right = '>>',
        up = '<M-s>',
        down = '<M-d>',

        line_right = '>>',
        line_left = '<<',
        line_up = '<M-s>',
        line_down = '<M-d>',
      },

      options = {
        reindent_linewise = true,
      }
    })
  end
}

local cursorword = {
  'echasnovski/mini.cursorword',
  version = '*',
  config = function()
    require('mini.cursorword').setup({})
  end
}

local files = {
  'echasnovski/mini.files',
  version = '*',
  config = function()
    require('mini.files').setup({})
  end
}

return { move, cursorword }

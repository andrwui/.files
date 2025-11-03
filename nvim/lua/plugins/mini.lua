local move = {
  'echasnovski/mini.move',
  version = '*',
  config = function()
    require('mini.move').setup({

      mappings = {
        left = '<<',
        right = '>>',
        up = '<C-s>',
        down = '<C-d>',

        line_right = '>>',
        line_left = '<<',
        line_up = '<C-s>',
        line_down = '<C-d>',
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

--[[
local files = {
  'echasnovski/mini.files',
  version = '*',
  config = function()
    require('mini.files').setup({})
  end
}
]]

local surround = {

  'echasnovski/mini.surround',

  version = '*',

  config = function()
    require('mini.surround').setup({
      mappings = {
        add = '<Leader>a',
        delete = '<Leader>d',
        find = '',
        find_left = '',
        highlight = '',
        replace = '<Leader>r',
        update_n_lines = '',
      }

    })
  end
}

local diff = {
  "echasnovski/mini.diff",
  config = function()
    local diff = require("mini.diff")
    diff.setup({
      -- Disabled by default
      source = diff.gen_source.none(),
    })
  end,
}


return { move, cursorword, surround, diff }

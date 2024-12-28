# scrollbar just to see errors in large files

local scrollbar = {
  'petertriho/nvim-scrollbar',
  config = function()
    require('scrollbar').setup({})
  end
}


return { scrollbar }

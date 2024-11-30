-- comments lines, works like dogshit for blockwise or i'm just fucking stupid which is the most probable cause why this wont work
local comment = {
  'numToStr/Comment.nvim',

  config = function()
    require('Comment').setup()
  end
}


return { comment }

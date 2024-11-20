-- buffer lines... duh
local bufferline = {
  'akinsho/bufferline.nvim',
  config = function()
    require('bufferline').setup {}
  end
}

return { bufferline }

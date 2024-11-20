-- buffer lines... duh
local bufferline = {
  'akinsho/bufferline.nvim',
  config = function()
    require('bufferline').setup({
      options = {
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'tree',
            text_align = 'center',
            separator = true,
            diagnostics = 'nvim_lsp',
          }
        }
      }
    })
  end
}

return { bufferline }

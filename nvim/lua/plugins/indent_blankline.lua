-- indentation indicators
local indent_blankline = {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    require('ibl').setup()
  end,
}




return { indent_blankline }

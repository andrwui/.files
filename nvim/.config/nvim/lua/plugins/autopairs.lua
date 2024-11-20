-- automatically pair brackets, wild this is not a default behavior in nvim tbh. 0/10 nvim

local autopairs = {
  "windwp/nvim-autopairs",
  config = function()
    require("nvim-autopairs").setup {}
  end
}


return { autopairs }

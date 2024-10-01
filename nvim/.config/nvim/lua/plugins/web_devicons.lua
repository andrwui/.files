local icons = {
  'nvim-tree/nvim-web-devicons',
  config = function()
    require('nvim-web-devicons').setup({ default = true })
  end,
}

local devicons = require('nvim-web-devicons')
local ico = devicons.get_icons()

for _, icon in pairs(ico) do
  icon.color = "#FFFFFF"
end

return { icons }

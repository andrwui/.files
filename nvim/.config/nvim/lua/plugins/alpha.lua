-- splash screen. i literally never see it, i just open my projects directly lmao. used for some nice posts on unixporn
local alpha = {
  "goolord/alpha-nvim",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local alpha = require('alpha')
    local dashboard = require('alpha.themes.dashboard')

    dashboard.section.header.val = {
      "███    ██ ███████  ██████  ██    ██ ██ ███    ███",
      "████   ██ ██      ██    ██ ██    ██ ██ ████  ████",
      "██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██",
      "██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██",
      "██   ████ ███████  ██████    ████   ██ ██      ██",
      "                                                  ",
      "                                                  ",
    }

    alpha.setup(dashboard.opts)
  end
}

return { alpha }

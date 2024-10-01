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

local codecompanion = {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = "openrouter",
      },
      inline = {
        adapter = "openrouter",
      }
    },
    adapters = {
      http = {
        openrouter = function()
          return require('codecompanion.adapters').extend("openai_compatible", {
            env = {
              url = 'http://localhost:6969/',
              chat_url = 'chat/completions',
            },
            schema = {
              model = {
                default = "mistralai/devstral-2512:free",
              }
            }
          })
        end
      }
    }
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}

return { codecompanion }

local codecompanion = {
  "olimorris/codecompanion.nvim",
  opts = {
    strategies = {
      chat = {
        adapter = "anthropic",
        model = "claude-3-5-haiku-20241022"
      },
      inline = {
        adapter = "anthropic",
        model = "claude-3-5-haiku-20241022"
      }
    },
    adapters = {
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-3-5-haiku-20241022",
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

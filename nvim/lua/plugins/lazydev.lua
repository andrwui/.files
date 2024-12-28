-- supposedly enables lsp for lua. i'm definitely not getting auto completions, but errors i have anywhere. i am doomed to err
local lazydev = {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      { path = "luvit-meta/library", words = { "vim%.uv" } },
    },
  },
}

return { lazydev }

-- muse.nvim — right-pane chat with pi (Muse Spark), LSP + file context included.
-- Local plugin living inside this config (lua/muse/). To extract it later,
-- copy lua/muse/ into its own repo as lua/muse/ and keep this spec (with dir
-- pointed at the checkout).
local muse = {
  name = "muse-nvim",
  dir = vim.fn.stdpath("config"),
  lazy = false,
  priority = 900,
  config = function()
    require("muse").setup({
      -- pi_bin = "pi",
      -- provider = nil, -- nil = your pi defaults (settings.json)
      -- model = nil, -- e.g. "anthropic/claude-sonnet-4-20250514"
      -- thinking = nil, -- e.g. "high"
      -- resume = false, -- true = reopen last session for this project
      -- approve = false, -- true = trust project-local pi resources (--approve)
      -- show_thinking = true, -- stream thinking blocks as normal Muse text
      -- auto_attach_file = true, -- auto-include current file on every send
      -- auto_attach_diagnostics = true, -- auto-include LSP diagnostics (only when non-empty)
      -- max_auto_file_lines = 1200, -- truncate auto-attached file
      width = 72,
      input_height = 10,
    })
  end,
}

return { muse }

local opencode = {
  "sudo-tee/opencode.nvim",
  config = function()
    require("opencode").setup({
      keymap = {
        editor = {
          ['<Leader>cc'] = { 'toggle' },
          ['<Leader>cy'] = { 'add_visual_selection' },
        }
      }
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- render-markdown is configured centrally in render_markdown.lua
    -- (monochrome overrides + all filetypes). Keep the dep bare so
    -- lazy.nvim doesn't create a second conflicting spec.
    "MeanderingProgrammer/render-markdown.nvim",
    'saghen/blink.cmp',

    'folke/snacks.nvim',
  },
}

return { opencode }

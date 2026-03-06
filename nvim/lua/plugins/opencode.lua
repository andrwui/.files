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
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
        file_types = { 'markdown', 'opencode_output' },
      },
      ft = { 'markdown', 'Avante', 'copilot-chat', 'opencode_output' },
    },
    'saghen/blink.cmp',

    'folke/snacks.nvim',
  },
}

return { opencode }

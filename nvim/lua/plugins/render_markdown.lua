return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown", "codecompanion" },
  config = function()
    require('render-markdown').setup({
      code = {
        enabled = true,
        sign = false,
        style = 'full',
        left_pad = 0,
        right_pad = 0,
        width = 'full',
        border = 'thin',
        language_map = {
          tsx = 'typescriptreact',
          ts = 'typescript',
        },
      },
    })
  end
}

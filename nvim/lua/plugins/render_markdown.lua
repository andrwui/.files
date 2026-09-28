return {
  "MeanderingProgrammer/render-markdown.nvim",
  -- single spec for all markdown consumers (muse chat, opencode output, …).
  -- opencode.lua also lists this plugin as a dependency; lazy.nvim merges
  -- duplicate specs, so keep filetypes + opts in sync here.
  ft = { "markdown", "codecompanion", "Avante", "copilot-chat", "opencode_output" },
  config = function()
    require('render-markdown').setup({
      file_types = { 'markdown', 'opencode_output', 'codecompanion', 'Avante', 'copilot-chat' },
      -- muse://input is the editable prompt box: keep it plain text.
      -- (muse://chat keeps full rendering.)
      ignore = function(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        return name:match('muse://input') ~= nil
      end,
      anti_conceal = { enabled = false },
      heading = {
        enabled = true,
        sign = false,
        width = 'block',
        min_width = 24,
        border = true,
      },
      code = {
        enabled = true,
        sign = false,
        style = 'full',
        left_pad = 1,
        right_pad = 1,
        width = 'full',
        border = 'thin',
        language_map = {
          tsx = 'typescriptreact',
          ts = 'typescript',
        },
      },
      bullet = { enabled = true },
      checkbox = { enabled = true },
      quote = { enabled = true },
    })

    -- Monochrome overrides: render-markdown's defaults are colorful
    -- (blue H1, green code bg, …). Keep the structure (bold, borders,
    -- backgrounds) but in greys so the pane matches the monochrome theme.
    local function mono_hl()
      local bg = vim.o.background
      if bg == 'light' then
        vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#000000', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#000000', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#222222', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#333333', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#444444', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#555555', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#e0e0e0', fg = '#000000', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#e8e8e8', fg = '#000000', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = '#e8e8e8', fg = '#222222' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder', { fg = '#a0a0a0', bg = '#e8e8e8' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline', { bg = '#e0e0e0', fg = '#000000' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = '#000000' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownQuote', { fg = '#555555' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownDash', { fg = '#a0a0a0' })
      else
        vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#ffffff', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#ffffff', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#e8e8e8', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#d0d0d0', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#b0b0b0', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#909090', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#2e2e2e', fg = '#ffffff', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#262626', fg = '#ffffff', bold = true })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCode', { bg = '#1e1e1e', fg = '#d4d4d4' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCodeBorder', { fg = '#505050', bg = '#1e1e1e' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownCodeInline', { bg = '#2e2e2e', fg = '#ffffff' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownBullet', { fg = '#ffffff' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownQuote', { fg = '#a0a0a0' })
        vim.api.nvim_set_hl(0, 'RenderMarkdownDash', { fg = '#505050' })
      end
    end
    mono_hl()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('MuseRenderMarkdownMono', { clear = true }),
      callback = mono_hl,
    })
  end
}

-- markdown previewer irt. ima prolly get rid of it, kinda sucks to have to open it in the browser. also it breaks every update but somehow works?
return {
  -- Install markdown preview, use npx if available.
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  build = "cd app && npm install",
  init = function()
    if vim.fn.executable "npx" then vim.g.mkdp_filetypes = { "markdown" } end
  end,
}

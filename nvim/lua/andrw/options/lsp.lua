vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = {
    { "🭽", "White" },
    { "▔", "White" },
    { "🭾", "White" },
    { "▕", "White" },
    { "🭿", "White" },
    { "▁", "White" },
    { "🭼", "White" },
    { "▏", "White" },
  }
})


vim.filetype.add({
  extension = {
    mdx = "mdx"
  }
})

return {}

vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true,
})

vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { undercurl = true, sp = '#E7AFA8' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = '#E5CC87' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { underline = true, sp = '#FFFFFF' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { underline = true, sp = '#080808' })

return {}

vim.wo.number = true


vim.diagnostic.config({
  update_in_insert = true,
  virtual_text = true
})



vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.o.signcolumn = "yes"
vim.o.fillchars = "eob: "

vim.opt.autoread = true
vim.opt.swapfile = false

vim.diagnostic.config({
  undercurl = true, -- Enable underlining for all severities
})

vim.api.nvim_set_hl(0, 'DiagnosticUnderlineError', { underline = true, sp = '#E7AFA8' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineWarn', { underline = true, sp = '#E5CC87' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineInfo', { underline = true, sp = '#00FFFF' })
vim.api.nvim_set_hl(0, 'DiagnosticUnderlineHint', { underline = true, sp = '#00FF00' })

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

-- NVIM TREE COLORS
vim.cmd [[
  hi Normal guibg=NONE ctermbg=NONE
  hi NonText guibg=NONE ctermbg=NONE
  highlight NvimTreeFolderIcon guifg=#ffffff
  highlight NvimTreeFolderName guifg=#ffffff
  highlight NvimTreeOpenedFolderName guifg=#ffffff
  highlight NvimTreeEmptyFolderName guifg=#ffffff
  highlight NvimTreeIndentMarker guifg=#ffffff
  highlight NvimTreeSymlink guifg=#ffffff
  highlight NvimTreeRootFolder guifg=#ffffff
  highlight NvimTreeExecFile guifg=#ffffff
  highlight NvimTreeOpenedFile guifg=#ffffff
  highlight NvimTreeSpecialFile guifg=#ffffff
  highlight NvimTreeImageFile guifg=#ffffff
  highlight NvimTreeGitDirty guifg=#ffffff
  highlight NvimTreeGitStaged guifg=#ffffff
  highlight NvimTreeGitMerge guifg=#ffffff
  highlight NvimTreeGitRenamed guifg=#ffffff
  highlight NvimTreeGitNew guifg=#ffffff
  highlight NvimTreeGitDeleted guifg=#ffffff
  highlight NvimTreeGitIgnored guifg=#ffffff
]]

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

  highlight BlinkCmpMenu guifg=#ffffff
  highlight BlinkCmpMenuBorder guibg=#ffffff
  highlight BlinkCmpMenuSelection guibg=#ffffff guifg=#0a0a0a gui=bold
  highlight BlinkCmpScrollBarThumb guibg=#ffffff

]]

vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#ffffff', italic = true })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'PmenuSel', { fg = '#ffffff', bg = '#404040' })
vim.api.nvim_set_hl(0, 'PmenuSbar', { bg = '#404040' })
vim.api.nvim_set_hl(0, 'PmenuThumb', { bg = '#808080' })
vim.api.nvim_set_hl(0, 'WildMenu', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'StatusLine', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'PmenuSel', { fg = '#ffffff', bg = '#404040' })
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Special', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'NonText', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'MoreMsg', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'Question', { fg = '#808080' })

return {}

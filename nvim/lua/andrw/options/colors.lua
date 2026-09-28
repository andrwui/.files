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
vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'NormalFloat', { fg = '#808080', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Special', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'SpecialKey', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'NonText', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'MoreMsg', { fg = '#808080' })
vim.api.nvim_set_hl(0, 'Question', { fg = '#808080' })

-- Monochrome diffs + chat markdown: the base `monochrome` colorscheme
-- paints DiffAdd/Delete green/red and headings blue. Keep the structure
-- (bold, bg shades, gutters) but in greys, so muse + opencode panes
-- stay legible without color.
local function mono_overrides()
  local light = vim.o.background == 'light'
  if light then
    vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#d8d8d8', fg = '#000000', bold = true })
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#efefef', fg = '#707070' })
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#e4e4e4', fg = '#000000' })
    vim.api.nvim_set_hl(0, 'DiffText', { bg = '#c8c8c8', fg = '#000000', bold = true })
    vim.api.nvim_set_hl(0, 'Added', { fg = '#000000', bold = true })
    vim.api.nvim_set_hl(0, 'Removed', { fg = '#707070' })
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#000000' })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#707070' })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#505050' })
    -- opencode.nvim ships green/red diff bgs; force them grey too.
    vim.api.nvim_set_hl(0, 'OpencodeDiffAdd', { bg = '#d8d8d8' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDelete', { bg = '#efefef' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffAddText', { fg = '#000000', bold = true })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDeleteText', { fg = '#707070' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffGutter', { fg = '#909090', bg = '#e0e0e0' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffAddGutter', { fg = '#000000', bg = '#c8c8c8', bold = true })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDeleteGutter', { fg = '#707070', bg = '#e0e0e0' })
    vim.api.nvim_set_hl(0, 'OpencodeReasoningText', { fg = '#707070', italic = true })
  else
    vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#2e2e2e', fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#222222', fg = '#808080' })
    vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#2a2a2a', fg = '#ffffff' })
    vim.api.nvim_set_hl(0, 'DiffText', { bg = '#3a3a3a', fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'Added', { fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'Removed', { fg = '#808080' })
    vim.api.nvim_set_hl(0, 'GitSignsAdd', { fg = '#ffffff' })
    vim.api.nvim_set_hl(0, 'GitSignsDelete', { fg = '#808080' })
    vim.api.nvim_set_hl(0, 'GitSignsChange', { fg = '#a0a0a0' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffAdd', { bg = '#2e2e2e' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDelete', { bg = '#222222' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffAddText', { fg = '#ffffff', bold = true })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDeleteText', { fg = '#808080' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffGutter', { fg = '#6b7280', bg = '#1a1a1a' })
    vim.api.nvim_set_hl(0, 'OpencodeDiffAddGutter', { fg = '#ffffff', bg = '#2e2e2e', bold = true })
    vim.api.nvim_set_hl(0, 'OpencodeDiffDeleteGutter', { fg = '#808080', bg = '#222222' })
    vim.api.nvim_set_hl(0, 'OpencodeReasoningText', { fg = '#808080', italic = true })
  end
end
mono_overrides()
vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('MonoDiffOverrides', { clear = true }),
  callback = mono_overrides,
})

return {}

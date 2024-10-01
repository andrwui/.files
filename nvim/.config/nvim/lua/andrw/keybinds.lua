-- DECLARATIONS

local opts = { noremap = true, silent = true }

local remap = function(modes, remap, action)
  vim.keymap.set(modes, remap, action, opts)
end

local unmap = function(modes, unmap)
  remap(modes, unmap, '<NOP>')
end

-- UNMAPPINGS
unmap({ 'n', 'v' }, 'h')
unmap({ 'n', 'v' }, 'j')
unmap({ 'n', 'v' }, 'J')
unmap({ 'n', 'v' }, 'u')
unmap({ 'n', 'v' }, 'w')
unmap({ 'n', 'v' }, 'W')
unmap({ 'n', 'v' }, '0')
unmap({ 'n', 'v' }, '$')
unmap({ 'n', 'v' }, '<Up>')
unmap({ 'n', 'v' }, '<Down>')
unmap({ 'n', 'v' }, '<Left>')
unmap({ 'n', 'v' }, '<Right>')
unmap({ 'n', 'v' }, '<PageUp>')
unmap({ 'n', 'v' }, '<PageDown>')
unmap({ 'n', 'v' }, 'yy')
unmap({ 'n', 'v' }, '<C-d>')
unmap({ 'n', 'v' }, '<C-a>')
unmap({ 'n', 'v' }, '<C-r>')
unmap({ 'n', 'v' }, '[[')
unmap({ 'n', 'v' }, ']]')
unmap({ 'n', 'v' }, '{')
unmap({ 'n', 'v' }, '}')
unmap({ 'n', 'v' }, '<<')
unmap({ 'n', 'v' }, '>>')

-- MAPPINGS

-- Vertical movement
-- Up and down
remap({ 'n', 'v' }, 'd', 'j')
remap({ 'n', 'v' }, 's', 'k')
-- Jump to clear lines
remap({ 'n', 'v' }, 'S', '{')
remap({ 'n', 'v' }, 'D', '}')
-- Jump to bottom and top
remap({ 'n', 'v' }, '<Leader>s', '[[')
remap({ 'n', 'v' }, '<Leader>d', ']]')

-- Horizontal movement
-- Right
remap({ 'n', 'v' }, 'l', 'l')
remap({ 'n', 'v' }, '<S-l>', 'w')
remap({ 'n' }, '<C-l>', '$')
remap({ 'v' }, '<C-l>', '$h')
-- Left
remap({ 'n', 'v' }, 'k', 'h')
remap({ 'n', 'v' }, '<S-k>', 'b')
remap({ 'n', 'v' }, '<C-k>', '0')

-- Yank to the clipboard
remap({ 'n', 'v' }, 'Y', '"+yy')
remap({ 'v' }, 'yy', '"+y')

-- Cut entire line
remap({ 'n', 'v' }, 'X', 'dd')

-- Default behavior of 'p' in visual mode is dogshit
remap({ 'v' }, 'p', 'P')

-- Select all
remap({ 'n', 'v' }, '<C-a>', '[[V]]')

-- Delete current line
remap({ 'n', 'v' }, '<C-d>', '"_dd')

-- Undo and redo
remap({ 'n', 'v' }, '<C-z>', 'u')
remap({ 'n', 'v' }, '<C-y>', '<C-r>')
remap('i', '<C-z>', '<Esc>ui')

-- Change between panes
remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')

-- Remap indent
remap({ 'n', 'v' }, '<', '<<')
remap({ 'n', 'v' }, '>', '>>')

-- Toggle NvimTree
remap('n', '<C-b>', ':NvimTreeToggle<CR>')

-- Add empty line with enter
remap({ 'n', 'v' }, '<CR>', 'o<Esc>')

-- Show hover snippet with -
remap('n', '-', function()
  vim.lsp.buf.hover()
end)

-- Diagnostic snippet with _
remap('n', '_', function()
  vim.diagnostic.open_float(nil, { border = 'single' })
end)

-- Rename namespace with C-r
remap('n', '<C-r>', function()
  vim.lsp.buf.rename()
end)

-- If error != nil for golang
local en = 'iif<Space>err<Space>!=<Space>nil<Space>{<Return><Return>}<Esc>ki'
remap('n', '<Leader>en', en)

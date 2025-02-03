-- DECLARATIONS

local opts = { noremap = true, silent = true }

local remap = function(modes, remap, action)
  vim.keymap.set(modes, remap, action, opts)
end

local unmap = function(modes, unmap)
  remap(modes, unmap, '<NOP>')
end

-- UNMAPPINGS
unmap({ 'n', 'v', 's' }, 'h')
unmap({ 'n', 'v', 's' }, 'H')
unmap({ 'n', 'v', 's' }, '<C-h>')
unmap({ 'n', 'v', 's' }, 'j')
unmap({ 'n', 'v', 's' }, 'w')
unmap({ 'n', 'v', 's' }, 'W')
unmap({ 'n', 'v', 's' }, '0')
unmap({ 'n', 'v', 's' }, '$')
unmap({ 'n', 'v', 's', 'i' }, '<Up>')
unmap({ 'n', 'v', 's', 'i' }, '<Down>')
unmap({ 'n', 'v', 's', 'i' }, '<Left>')
unmap({ 'n', 'v', 's', 'i' }, '<Right>')
unmap({ 'n', 'v', 's', 'i' }, '<PageUp>')
unmap({ 'n', 'v', 's', 'i' }, '<PageDown>')
unmap({ 'n', 'v', 's' }, '<C-d>')
unmap({ 'n', 'v', 's' }, '<C-a>')
unmap({ 'n', 'v', 's' }, '<C-r>')
unmap({ 'n', 'v', 's' }, '[[')
unmap({ 'n', 'v', 's' }, ']]')
unmap({ 'n', 'v', 's' }, '{')
unmap({ 'n', 'v', 's' }, '}')
unmap({ 'n', 'v', 's' }, '<<')
unmap({ 'n', 'v', 's' }, '>>')

-- MAPPINGS



--spider-nvim for actually good hor movement...

local sp_motion = require('spider').motion

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
  remap({ 'n', 'v' }, '<S-l>', function()
    sp_motion('w')
  end)

remap({ 'n', 'o' }, '<C-l>', '$')
remap({ 'v' }, '<C-l>', '$h')

-- Left
remap({ 'n', 'v' }, 'k', 'h')
remap({ 'n', 'v' }, '<S-k>', function()
  sp_motion('b')
end)
remap({ 'n', 'v' }, '<C-k>', '0')
remap({ 'n', 'v' }, '<C-S-k>', '0<S-l>')

-- Yank to the clipboard
remap({ 'n', 'v' }, 'y', '"+y')
remap({ 'n' }, 'yy', '"+yy')

-- Cut
remap({ 'n', 'v' }, 'x', '"+d')
remap({ 'n', 'v' }, '<Del>', '"_x')

-- c to black hole, if i wanted to cut i would do that.
remap({ 'n', 'v' }, 'c', '"_c')

-- Paste
remap({ 'v' }, 'p', '"+p')

-- Select all
remap({ 'n', 'v' }, '<C-a>', '[[V]]')

-- Remap delete to j
remap({ 'n', 'v' }, 'j', '"_d')

-- Delete current line
remap({ 'n', 'v' }, '<C-d>', '"_dd')

-- Run normal mode commands in insert mode with <C-b> because my tmux prefix is <C-o>
remap({ 'i' }, '<C-b>', '<C-o>')

-- Redo to U
remap({ 'n' }, 'U', '<C-r>')

-- Change between panes
remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')

-- Remap indent
remap({ 'n', 'v' }, '<<', '<<')
remap({ 'n', 'v' }, '>>', '>>')

remap({ 'n' }, '<C-x>', '<C-a>')
remap({ 'n' }, '<C-S-x>', '<C-x>')

remap({ 'n', 'v' }, '<CR>', 'o<Esc>')

remap({ 'n' }, '<C-o>', '<BS>')



-- Show hover snippet with -
remap('n', '-', function()
  vim.lsp.buf.hover()
end)

-- Diagnostic snippet with _
remap('n', '_', function()
  vim.diagnostic.open_float(nil, { border = 'single' })
end)

-- Toggle NvimTree
remap('n', '<C-b>', ':NvimTreeToggle<CR>')

-- Rename namespace with C-r
remap("n", "<C-r>", function()
  vim.lsp.buf.rename()
end)

-- Kill current buffer
remap('n', '<Leader><BS>', function()
  vim.cmd('bdelete')
end)

-- Generate Golang json tags for current line and jump downards
remap('n', '<Leader>gj',
  "^yiwA<Space>`json:\"<Esc>pa\"`<Esc>F\"F\"l~F`i<CR><Esc>V:s/\\u/_\\L&/ge<CR>:noh<CR>kJj^")

-- Comment
local commentapi = require('Comment.api')
remap({ 'n' }, '<S-c>', function()
  commentapi.toggle.linewise.current()
end)

remap({ 'v' }, '<S-c>', function()
  commentapi.toggle.blockwise.current(vim.fn.visualmode())
end)

vim.keymap.set('n', 'gT', function()
  vim.lsp.buf.type_definition()
  vim.schedule(function()
    vim.cmd('normal! <C-o>')
  end)
end)

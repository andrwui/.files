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
unmap({ 'n', 'v', 's' }, '<C-j>')
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
unmap({ 'n', 'v', 's' }, 'yy')
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
remap({ 'n', 'o' }, '<C-l>', '$')
remap({ 'v' }, '<C-l>', '$h')
-- Left
remap({ 'n', 'v' }, 'k', 'h')
remap({ 'n', 'v' }, '<S-k>', 'b')
remap({ 'n', 'v' }, '<C-k>', '^')

-- Yank to the clipboard
remap({ 'n', 'v' }, 'Y', '"+yy')
remap({ 'v' }, 'yy', '"+y')

-- Cut entire line
remap({ 'n', 'v' }, 'X', 'dd')

-- Default behavior of 'p' in visual mode is dogshit
remap({ 'v' }, 'p', 'P')

-- Select all
remap({ 'n', 'v' }, '<Leader>a', '[[V]]')

-- Delete current line
remap({ 'n', 'v' }, '<C-d>', '"_dd')

-- Remap delete to e
remap({ 'n', 'v' }, 'e', 'd')

-- Run normal mode commands in insert mode with <C-b> because my tmux prefix is <C-o>
remap({ 'i' }, '<C-b>', '<C-o>')

-- Undo and redo
remap({ 'n', 'v' }, '<C-y>', '<C-r>')

-- Change between panes
remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')

-- Remap indent
remap({ 'n', 'v' }, '<<', '<<')
remap({ 'n', 'v' }, '>>', '>>')

remap({ 'n' }, '<C-x>', '<C-a>')
remap({ 'n' }, '<C-S-x>', '<C-x>')

-- Add empty line up and down with enter
remap({ 'n', 'v' }, '<CR>', 'o<Esc>')
remap({ 'n', 'v' }, '<CR>', 'o<Esc>')

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

-- Rename namespace (with vim motions!!!) with C-r
remap("n", "<C-r>", function()
  vim.lsp.buf.rename()
end)


-- Generate Golang json tags for current line and jump downards
remap('n', '<Leader>gj',
  "^yiwA<Space>`json:\"<Esc>pa\"`<Esc>F\"F\"l~F`i<CR><Esc>V:s/\\u/_\\L&/ge<CR>:noh<CR>kJj^")


local cycle_buffers = function(direction)
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local current = vim.fn.bufnr('%')
  local index = 0

  for i, buf in ipairs(buffers) do
    if buf.bufnr == current then
      index = i
      break
    end
  end

  if direction == 'next' then
    index = index % #buffers + 1
  else
    index = index - 1
    if index == 0 then
      index = #buffers
    end
  end

  vim.cmd('buffer ' .. buffers[index].bufnr)
end

local kill_buffer = function()
  local current_buffer = vim.fn.bufnr('%')
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  if #buffers <= 1 then
    vim.cmd('bdelete! ' .. current_buffer)
    return
  end

  local next_buffer
  for i, buf in ipairs(buffers) do
    if buf.bufnr == current_buffer then
      next_buffer = buffers[(i % #buffers) + 1].bufnr
      break
    end
  end

  if next_buffer then
    vim.cmd('buffer ' .. next_buffer)
    vim.cmd('bdelete! ' .. current_buffer)
  end
end

remap('n', '<Leader>x', function() kill_buffer() end)
remap('n', '<Leader><BS>', function()
  kill_buffer()
end)

remap('n', '<Leader>gg', function()
  cycle_buffers('prev')
end)
remap('n', '<Leader>hh', function()
  cycle_buffers('next')
end)

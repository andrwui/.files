local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')
remap({ 'n', 'v' }, '<Leader>s', '<C-w><Up>')
remap({ 'n', 'v' }, '<Leader>d', '<C-w><Down>')

remap('n', '<C-b>', ':NvimTreeToggle<CR>')

remap('n', '<Leader><BS>', function()
  vim.cmd('bdelete')
end)

return {}

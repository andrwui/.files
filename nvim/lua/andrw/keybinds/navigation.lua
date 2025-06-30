local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')
remap({ 'n', 'v' }, '<Leader>s', '<C-w><Up>')
remap({ 'n', 'v' }, '<Leader>d', '<C-w><Down>')

remap({ 'n' }, '<Leader>L', function()
  vim.cmd('vsplit')
  require('oil').open(vim.fn.getcwd())
end)

remap({ 'n' }, '<Leader>D', function()
  vim.cmd('split')
  require('oil').open(vim.fn.getcwd())
end)

remap('n', '<Leader><BS>', function()
  vim.cmd('bdelete')
end)

return {}

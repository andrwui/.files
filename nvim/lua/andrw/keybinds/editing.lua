local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap({ 'n', 'v' }, 'j', '"_d')
remap({ 'n', 'v' }, 'jj', '"_dd')

remap({ 'n', 'v' }, '<C-j>', '"_dd')

remap({ 'i' }, '<C-b>', '<C-o>')

remap({ 'n' }, 'U', '<C-r>')

remap({ 'n', 'v' }, '<CR>', 'o<Esc>')

remap({ 'n' }, '<C-o>', '<BS>')

remap({ 'n' }, '<C-x>', '<C-a>')
remap({ 'n' }, '<C-S-x>', '<C-x>')

remap({ 'n', 'v', 'i' }, '<Tab>', '<Tab>')

local commentapi = require('Comment.api')
remap({ 'n' }, '<S-c>', function()
  commentapi.toggle.linewise.current()
end)

remap({ 'v' }, '<S-c>', function()
  commentapi.toggle.blockwise.current(vim.fn.visualmode())
end)

return {}

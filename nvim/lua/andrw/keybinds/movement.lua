local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

local sp_motion = require('spider').motion

remap({ 'n', 'v' }, 'd', 'j')
remap({ 'n', 'v' }, 's', 'k')

remap({ 'n', 'v' }, 'S', '{')
remap({ 'n', 'v' }, 'D', '}')

remap({ 'n', 'v' }, '<Leader>s', '[[')
remap({ 'n', 'v' }, '<Leader>d', ']]')

remap({ 'n', 'v' }, 'l', 'l')
remap({ 'n', 'v' }, '<S-l>', function()
  sp_motion('w')
end)

remap({ 'n', 'o' }, '<C-l>', '$')
remap({ 'v' }, '<C-l>', '$h')

remap({ 'n', 'v' }, 'k', 'h')
remap({ 'n', 'v' }, '<S-k>', function()
  sp_motion('b')
end)

remap({ 'n', 'v' }, '<C-k>', '^')
remap({ 'n', 'v' }, '<C-S-k>', '^<S-k>')

return {}

local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap({ 'n', 'v' }, 'y', '"+y')
remap({ 'n' }, 'yy', '"+yy')

remap({ 'n', 'v' }, 'x', '"+d')
remap({ 'n', 'v' }, '<Del>', '"_x')

remap({ 'n', 'v' }, 'c', '"_c')

remap('n', 'p', '"+p')
remap('n', 'P', '"+P')

remap('v', 'p', '"_d"+P')
remap('v', 'P', '"_d"+P')

remap({ 'n', 'v' }, '<C-a>', 'gg0vG$')

return {}

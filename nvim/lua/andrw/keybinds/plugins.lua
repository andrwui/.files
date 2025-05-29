local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

-- CodeCompanion

remap({ 'n' }, "<Leader>cc", "<cmd>CodeCompanionChat<CR>")
remap({ 'n' }, "<Leader>ii", "<cmd>CodeCompanion<CR>")

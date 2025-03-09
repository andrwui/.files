local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

-- Generate Golang json tags for current line and jump downwards
remap('n', '<Leader>gj',
  "^yiwA<Space>`json:\"<Esc>pa\"`<Esc>F\"F\"l~F`i<CR><Esc>V:s/\\u/_\\L&/ge<CR>:noh<CR>kJj^")

return {}

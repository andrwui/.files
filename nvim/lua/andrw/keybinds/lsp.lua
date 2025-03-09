local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap('n', '-', function()
  vim.lsp.buf.hover()
end)

remap('n', '_', function()
  vim.diagnostic.open_float(nil, { border = 'single' })
end)

remap("n", "<C-r>", function()
  vim.lsp.buf.rename()
end)

vim.keymap.set('n', 'gT', function()
  vim.lsp.buf.type_definition()
  vim.schedule(function()
    vim.cmd('normal! <C-o>')
  end)
end)

return {}

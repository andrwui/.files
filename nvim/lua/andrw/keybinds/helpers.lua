local M = {}

M.opts = { noremap = true, silent = true }

M.remap = function(modes, remap, action)
  vim.keymap.set(modes, remap, action, M.opts)
end

M.unmap = function(modes, unmap)
  M.remap(modes, unmap, '<NOP>')
end

return M

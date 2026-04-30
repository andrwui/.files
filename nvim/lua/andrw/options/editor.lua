vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.relativenumber = false
vim.opt.number = true

vim.opt.swapfile = false
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    if vim.fn.getcmdwintype() == '' then
      vim.cmd('checktime')
    end
  end
})

vim.opt.wrap = false
vim.opt.scrolloff = 10

vim.opt.splitright = true
vim.opt.splitbelow = true


vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "latin1" }

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.bo.fileencoding = "utf-8"
  end
})

return {}

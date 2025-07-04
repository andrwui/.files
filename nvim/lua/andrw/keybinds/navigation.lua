local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

remap({ 'n', 'v' }, '<Leader>k', '<C-w><Left>')
remap({ 'n', 'v' }, '<Leader>l', '<C-w><Right>')
remap({ 'n', 'v' }, '<Leader>s', '<C-w><Up>')
remap({ 'n', 'v' }, '<Leader>d', '<C-w><Down>')


local function fd_split(split_cmd)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  require('telescope.builtin').fd({
    attach_mappings = function()
      actions.select_default:replace(function(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry or not entry.path then return end
        vim.cmd(split_cmd)
        vim.cmd('edit ' .. vim.fn.fnameescape(entry.path))
      end)
      return true
    end,
  })
end

remap({ 'n' }, '<Leader>L', function()
  fd_split('vsplit')
end)

remap({ 'n' }, '<Leader>D', function()
  fd_split('split')
end)


remap('n', '<Leader><BS>', function()
  vim.cmd('bdelete')
end)

return {}

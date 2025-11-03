local helpers = require('andrw.keybinds.helpers')
local remap = helpers.remap

local function get_java_package_and_class()
  -- Get all lines in the current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local package_line = ""
  local class_name = ""
  -- Find the package line
  for _, line in ipairs(lines) do
    if line:match("^%s*package%s+[%w%.]+;") then
      package_line = line:match("package%s+([%w%.]+);")
      break
    end
  end
  -- Find the class name line
  for _, line in ipairs(lines) do
    -- Match public, private, or default class declaration
    local match = line:match("%s*[public%s+|private%s+|protected%s+]*class%s+([%w_]+)")
    if match then
      class_name = match
      break
    end
  end
  -- Combine package and class
  local full_name = ""
  if package_line ~= "" then
    full_name = package_line .. "." .. class_name
  else
    full_name = class_name
  end
  -- Copy to clipboard
  vim.fn.setreg('+', full_name)
  vim.fn.setreg('"', full_name)
  -- Show notification
  print("Copied to clipboard: " .. full_name)
end

local function get_constant_name()
  -- Get the current file name without path
  local filename = vim.fn.expand('%:t')

  -- Remove file extension
  local name_without_ext = filename:match("(.+)%..+$") or filename

  -- Convert camelCase to UPPER_SNAKE_CASE
  local constant_name = name_without_ext
      -- Insert underscore before uppercase letters (except the first character)
      :gsub("(%l)(%u)", "%1_%2")
      -- Convert to uppercase
      :upper()

  -- Copy to clipboard
  vim.fn.setreg('+', constant_name)
  vim.fn.setreg('"', constant_name)

  -- Show notification
  print("Copied to clipboard: " .. constant_name)
end

-- Set up the keybindings
remap({ 'n' }, '<Leader>jc', function()
  get_java_package_and_class()
end)

remap({ 'n' }, '<Leader>cn', function()
  get_constant_name()
end)

return {}

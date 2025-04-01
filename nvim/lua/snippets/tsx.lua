local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function get_file_name()
  return vim.fn.expand("%:t:r")
end

return {
  s("rc", fmt([[
interface {}Props = {{}}

const {} = ({{}}: {}Props ) => {{
  {}
}}
export default {}
  ]], {
    f(get_file_name),
    f(get_file_name),
    f(get_file_name),
    i(1),
    f(get_file_name)
  }))
}


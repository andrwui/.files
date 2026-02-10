local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local function get_file_name()
  return vim.fn.expand("%:t:r")
end

return {
  s("rct", fmt([[
  type {}Props = {{}}

  export default function {}({{}}: {}Props ){{
    {}
  }}
  ]],
    {
      f(get_file_name),
      f(get_file_name),
      f(get_file_name),
      i(1),
    }
  )),

  s("rc", fmt([[
export default function {}(){{
  {}
}}
]],
    {
      f(get_file_name),
      i(1),
    }
  )),

  s("ec", fmt([[
export const {} = () => {{
  {}
}}
]],
    {
      f(get_file_name),
      i(1),
    }
  )),

  s("af", fmt([[
const {} = () => {{

}}
]],
    {
      f(1),
    }
  )),

  s("usestate", fmt([[
const [{}, set{}] = useState({})
]],
    {
      i(1),
      f(function(args)
        local str = args[1][1]
        return (str:gsub('^%l', string.upper))
      end, { 1 }),
      i(2),
    })),

  s("useeffect", fmt([[
  useEffect(() => {{
    {}
  }}, [])
]],
    {
      i(1),
    })),

  s("importmotion", { t("import * as motion from 'motion/react-client'"), i(1) }),
}

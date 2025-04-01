local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function camel_to_snake_case(str)
  return str:gsub("%u", function(c) return "_" .. c:lower() end):gsub("^_", "")
end

return {
  s("iferr", {
    t("if err != nil {"),
    t({ "", "\t" }), i(1),
    t({ "", "}" })
  }),

  s("enew", {
    t("errors.New(\""), i(1), t("\")")
  }),

  s("gostruct", {
    t("type "), i(1, "StructName"), t(" struct {"),
    t({ "", "	" }),
    f(function(args)
      local count = tonumber(args[1][1]) or 3
      local fields = {}
      for j = 1, count do
        local field_name = "Field" .. j
        local json_tag = camel_to_snake_case(field_name)
        table.insert(fields, field_name .. " string `json:\"" .. json_tag .. "\"`")
      end
      return table.concat(fields, "\n\t")
    end, { i(2, "3") }),
    t({ "", "}" }),
  })
}

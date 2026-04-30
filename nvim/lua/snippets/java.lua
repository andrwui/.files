local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- Utility functions
local function get_package_path()
  local file_path = vim.fn.expand("%:p")
  local src_index = string.find(file_path, "src/")
  if not src_index then return "" end
  local path_after_src = string.match(file_path, "src/(.+)/[^/]+%.java$")
  if not path_after_src then return "" end
  return string.gsub(path_after_src, "/", ".")
end

local function get_file_name()
  return vim.fn.expand("%:t:r")
end

return {
  s("apiaclass", fmt([[
package {};
import com.dogma.busClass.ApiaAbstractClass;
import com.dogma.busClass.BusClassException;
import com.dogma.busClass.object.*;

public class {} extends ApiaAbstractClass {{
  @Override
  protected void executeClass() throws BusClassException {{
    {}
  }}
}}
  ]], {
    f(get_package_path),
    f(get_file_name),
    i(1)
  }))
  ,
  s("att", fmt([[
Attribute {} = e.getAttribute("");
  ]], {
    i(1),
  }))
  ,
  s("param", fmt([[
Parameter {} = getParameter("");
  ]], {
    i(1),
  }))
}

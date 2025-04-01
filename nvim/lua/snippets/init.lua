local M = {}

function M.setup()
  local ls = require("luasnip")

  -- Load snippets for each language
  ls.add_snippets("go", require("snippets.go"))
  ls.add_snippets("java", require("snippets.java"))
  ls.add_snippets("typescriptreact", require("snippets.tsx"))
  ls.add_snippets("tex", require("snippets.tex"))

  -- Configure snippet options
  ls.config.set_config({
    updateevents = "TextChanged,TextChangedI"
  })
end

return M


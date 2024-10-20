-- plugins.luasnip
local luasnip = {
  "L3MON4D3/LuaSnip",
  version = 'v2.*',
  build = 'make install_jsregexp',
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node
    local f = ls.function_node
    local d = ls.dynamic_node
    local sn = ls.snippet_node
    local rep = require("luasnip.extras").rep
    ls.config.set_config {
      updateevents = "TextChanged,TextChangedI"
    }
    vim.keymap.set("n", "<space><space>s", "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>")
    vim.keymap.set({ "i", 's' }, "<C-l>", function() ls.jump(1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", 's' }, "<Tab>", function() ls.jump(1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", 's' }, "<C-k>", function() ls.jump(-1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", 's' }, "<Shift><Tab>", function() ls.jump(-1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", "s" }, "<C-E>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })


    local function camelToSnakeCase(str)
      return str:gsub('%f[^%l]%u', '_%1'):gsub('%f[^%a]%d', '_%1'):gsub('%f[^%d]%a', '_%1'):gsub('(%u)(%u%l)', '%1_%2')
          :lower()
    end

    local function mirrorSnakeCase(args, _, _)
      return camelToSnakeCase(args[1][1])
    end
    ls.add_snippets("go", {
      s("iferr", {
        t("if err != nil {"),
        t({ "", "\t" }), i(1),
        t({ "", "}" })
      }),

      s("gostruct", {
        t("type "), i(1, "StructName"), t(" struct {"),
        t({ "", "\t" }), i(2), t(" "), i(3), t(" `json:\""), f(mirrorSnakeCase, 2), t("\"`"),
        t({ "", "\t" }), i(4), t(" "), i(5), t(" `json:\""), f(mirrorSnakeCase, 4), t("\"`"),
        t({ "", "\t" }), i(6), t(" "), i(7), t(" `json:\""), f(mirrorSnakeCase, 6), t("\"`"),
        t({ "", "\t" }), i(8), t(" "), i(9), t(" `json:\""), f(mirrorSnakeCase, 8), t("\"`"),
        t({ "", "\t" }), i(10), t(" "), i(11), t(" `json:\""), f(mirrorSnakeCase, 10), t("\"`"),
        t({ "", "}" }),
      })
    })
  end
}


local luasnip_cmp = {
  'saadparwaiz1/cmp_luasnip',
  setup = function()
    require('cmp_luasnip').setup({})
  end
}
return { luasnip, luasnip_cmp }

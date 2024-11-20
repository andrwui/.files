-- cool snippets, actually a great plugin, one of my favs
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
    local fmt = require("luasnip.extras.fmt").fmt
    ls.config.set_config {
      updateevents = "TextChanged,TextChangedI"
    }
    vim.keymap.set("n", "<space><space>s", "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>")
    vim.keymap.set({ "i", 's' }, "<C-l>", function() ls.jump(1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", 's' }, "<C-k>", function() ls.jump(-1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", "s" }, "<C-E>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })


    local function get_package_path()
      local file_path = vim.fn.expand("%:p")
      local src_index = string.find(file_path, "src/")
      if not src_index then return "" end

      -- Get path after src/ and before filename
      local path_after_src = string.match(file_path, "src/(.+)/[^/]+%.java$")
      if not path_after_src then return "" end

      -- Replace slashes with dots
      return string.gsub(path_after_src, "/", ".")
    end

    local function get_class_name()
      return vim.fn.expand("%:t:r") -- Get filename without extension
    end

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

      s("ljstruct", {
        t("type "), i(1), t(" struct {"),
        t({ "", "\t" }), i(2), t(" "), i(3), t(" `json:\""), f(mirrorSnakeCase, 2), t("\"`"),
        t({ "", "\t" }), i(4), t(" "), i(5), t(" `json:\""), f(mirrorSnakeCase, 4), t("\"`"),
        t({ "", "\t" }), i(6), t(" "), i(7), t(" `json:\""), f(mirrorSnakeCase, 6), t("\"`"),
        t({ "", "\t" }), i(8), t(" "), i(9), t(" `json:\""), f(mirrorSnakeCase, 8), t("\"`"),
        t({ "", "\t" }), i(10), t(" "), i(11), t(" `json:\""), f(mirrorSnakeCase, 10), t("\"`"),
        t({ "", "\t" }), i(12), t(" "), i(13), t(" `json:\""), f(mirrorSnakeCase, 12), t("\"`"),
        t({ "", "\t" }), i(14), t(" "), i(15), t(" `json:\""), f(mirrorSnakeCase, 14), t("\"`"),
        t({ "", "\t" }), i(16), t(" "), i(17), t(" `json:\""), f(mirrorSnakeCase, 16), t("\"`"),
        t({ "", "\t" }), i(18), t(" "), i(19), t(" `json:\""), f(mirrorSnakeCase, 18), t("\"`"),
        t({ "", "\t" }), i(20), t(" "), i(21), t(" `json:\""), f(mirrorSnakeCase, 20), t("\"`"),
        t({ "", "\t" }), i(22), t(" "), i(23), t(" `json:\""), f(mirrorSnakeCase, 22), t("\"`"),
        t({ "", "\t" }), i(24), t(" "), i(25), t(" `json:\""), f(mirrorSnakeCase, 24), t("\"`"),
        t({ "", "\t" }), i(26), t(" "), i(27), t(" `json:\""), f(mirrorSnakeCase, 26), t("\"`"),
        t({ "", "\t" }), i(28), t(" "), i(29), t(" `json:\""), f(mirrorSnakeCase, 28), t("\"`"),
        t({ "", "\t" }), i(30), t(" "), i(31), t(" `json:\""), f(mirrorSnakeCase, 30), t("\"`"),
        t({ "", "\t" }), i(32), t(" "), i(33), t(" `json:\""), f(mirrorSnakeCase, 32), t("\"`"),
        t({ "", "\t" }), i(34), t(" "), i(35), t(" `json:\""), f(mirrorSnakeCase, 34), t("\"`"),
        t({ "", "\t" }), i(36), t(" "), i(37), t(" `json:\""), f(mirrorSnakeCase, 36), t("\"`"),
        t({ "", "\t" }), i(38), t(" "), i(39), t(" `json:\""), f(mirrorSnakeCase, 38), t("\"`"),
        t({ "", "}" }),
      }),

      s("jstruct", {
        t("type "), i(1), t(" struct {"),
        t({ "", "\t" }), i(2), t(" "), i(3), t(" `json:\""), f(mirrorSnakeCase, 2), t("\"`"),
        t({ "", "\t" }), i(4), t(" "), i(5), t(" `json:\""), f(mirrorSnakeCase, 4), t("\"`"),
        t({ "", "\t" }), i(6), t(" "), i(7), t(" `json:\""), f(mirrorSnakeCase, 6), t("\"`"),
        t({ "", "\t" }), i(8), t(" "), i(9), t(" `json:\""), f(mirrorSnakeCase, 8), t("\"`"),
        t({ "", "\t" }), i(10), t(" "), i(11), t(" `json:\""), f(mirrorSnakeCase, 10), t("\"`"),
        t({ "", "}" }),
      }),

      s("struct", {
        t("type "), i(1, "StructName"), t(" struct {"),
        t({ "", "\t" }), i(2), t(" "), i(3),
        t({ "", "\t" }), i(4), t(" "), i(5),
        t({ "", "\t" }), i(6), t(" "), i(7),
        t({ "", "\t" }), i(8), t(" "), i(9),
        t({ "", "\t" }), i(10), t(" "), i(11),
        t({ "", "}" }),
      })


    })


    ls.add_snippets("java", {
      s("apiaclass", fmt([[
        package {};

        import com.dogma.busClass.ApiaAbstractClass;
        import com.dogma.busClass.BusClassException;

        public class {} extends ApiaAbstractClass {{
          @Override
          protected void executeClass() throws BusClassException {{
            {}
          }}
        }}
      ]], {
        f(get_package_path),
        f(get_class_name),
        i(1)
      }))

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

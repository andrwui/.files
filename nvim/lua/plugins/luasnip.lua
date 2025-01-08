-- cool snippets, actually a great plugin, one of my favs
local luasnip = {
  "L3MON4D3/LuaSnip",
  version = 'v2.*',
  build = 'make install_jsregexp',
  config = function()
    local ls = require("luasnip")
    local types = require("luasnip.util.types")

    -- Basic configuration
    ls.config.set_config {
      updateevents = "TextChanged,TextChangedI"
    }

    -- Keymaps
    vim.keymap.set("n", "<space><space>s", "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>")
    vim.keymap.set({ "i", 's' }, "<C-l>", function() ls.jump(1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", 's' }, "<C-k>", function() ls.jump(-1) end, { silent = true, noremap = true })
    vim.keymap.set({ "i", "s" }, "<C-E>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true })

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

    -- Go snippets
    ls.add_snippets("go", {
      ls.snippet("iferr", {
        ls.text_node("if err != nil {"),
        ls.text_node({ "", "\t" }), ls.insert_node(1),
        ls.text_node({ "", "}" })
      }),
      ls.snippet("enew", {
        ls.text_node("errors.New(\""), ls.insert_node(1), ls.text_node("\")")
      })
    })

    -- Java snippets
    ls.add_snippets("java", {
      ls.snippet("apiaclass", require("luasnip.extras.fmt").fmt([[
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
        ls.function_node(get_package_path),
        ls.function_node(get_file_name),
        ls.insert_node(1)
      }))
    })

    -- TypeScript/React snippets
    ls.add_snippets("typescriptreact", {
      ls.snippet("rc", require("luasnip.extras.fmt").fmt([[
type {}Props = {{
}}
const {} = () => {{
  return <>{}</>
}}

export default {}
      ]], {
        ls.function_node(get_file_name),
        ls.function_node(get_file_name),
        ls.insert_node(1),
        ls.function_node(get_file_name)
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

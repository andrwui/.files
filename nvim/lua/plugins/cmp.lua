local cmp = {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'Kaiser-Yang/blink-cmp-avante',
  },

  version = '1.*',

  opts = {
    sources = {
      default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        avante = {
          module = 'blink-cmp-avante',
          name = 'Avante',
        }

      }
    },

    keymap = {
      preset = 'default',
      ['<CR>'] = { 'accept', 'fallback' },
      ['<Tab>'] = {},
    },

    snippets = { preset = 'luasnip' },

    appearance = {
      nerd_font_variant = 'mono'
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },
      ghost_text = {
        enabled = false
      }

    },

    fuzzy = { implementation = "prefer_rust_with_warning" },

    -- Disable for Dressing's popups, it's annoying
    enabled = function() return not vim.tbl_contains({ "DressingInput" }, vim.bo.filetype) end,

  },
  opts_extend = { "sources.default" }
}

return { cmp }

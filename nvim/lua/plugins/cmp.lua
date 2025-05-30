local cmp = {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'Kaiser-Yang/blink-cmp-avante',
  },

  version = '1.*',

  opts = {
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      per_filetype = {
        codecompanion = { "codecompanion" },
      },
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
      menu = {
        draw = {
          columns = {
            { "kind_icon", "label", gap = 2 },
          }
        }
      },

      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },

      ghost_text = {
        enabled = false
      },

      trigger = {
        show_on_blocked_trigger_characters = {
          ' ',
          '\n',
          '\t',
          '{',
          '(',
          '[',
          '}',
          ')',
          ']',
        },

        show_on_x_blocked_trigger_characters = {
          ' ',
          '\n',
          '\t',
          '{',
          '(',
          '[',
          '}',
          ')',
          ']',
        },

      },

      accept = {
        auto_brackets = {
          enabled = false
        }
      }

    },


    fuzzy = { implementation = "prefer_rust_with_warning" },

    enabled = function() return not vim.tbl_contains({ "DressingInput" }, vim.bo.filetype) end,

  },
  opts_extend = { "sources.default" }
}

return { cmp }

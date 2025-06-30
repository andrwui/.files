local colors = {
  bg = '#080808',
  fg = '#fafafa',
  dark = '#0f0f0f',
  light = '#404040'
}


local lualine = {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local ll = require('lualine')
    ll.setup {
      options = {
        icons_enabled = true,
        theme = {
          normal = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          insert = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          visual = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          replace = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          command = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
          inactive = {
            a = { bg = colors.dark, fg = colors.fg, gui = 'bold' },
            b = { bg = colors.bg, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg },
          },
        },
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 100,
          tabline = 100,
          winbar = 100,
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = { 'filename' },
        lualine_x = { 'filetype', 'lsp_status' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {}
    }
  end,
}

return { lualine }

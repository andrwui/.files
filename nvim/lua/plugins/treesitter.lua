local TS = {
  'nvim-treesitter/nvim-treesitter',
  branch = "main",
  build = ":TSUpdate",
  config = function()
    -- Fixed: Call the top-level 'nvim-treesitter' module instead of '.configs'
    local ts = require('nvim-treesitter')

    ts.setup({
      -- Fixed: Moved enable options into the required highlight sub-block
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      -- If you want indentation enabled, uncomment the line below:
      -- indent = { enable = true },

      ensure_installed = {
        'go',
        'javascript',
        'typescript',
        'tsx',
        'html',
        'astro',
        'css',
        'scss',
        'lua',
        'python',
        'bash',
        'diff',
        'gitcommit',
        'git_rebase',
        'markdown',
        'markdown_inline',
        -- filetypes that show up in muse/opencode edit blocks; without
        -- these the code fences fall back to plain grey and diffs look
        -- "very wrong". Missing parsers (e.g. tmux) safely fall back.
        'vim',
        'vimdoc',
        'json',
        'yaml',
        'toml',
      },
      ignore_install = { 'rust' }
    })
  end
}

return { TS }

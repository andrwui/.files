local TS = {

  'nvim-treesitter/nvim-treesitter',

  build = function()
    require('nvim-treesitter.install').update({ with_sync = true })()
  end,

  config = function()
    local confs = require('nvim-treesitter.configs')

    confs.setup({
      enable = true,
      aditional_vim_regex_highlighting = false,
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

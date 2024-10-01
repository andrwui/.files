local TS = {

  'nvim-treesitter/nvim-treesitter',

  build = function()
    require('nvim-treesitter.install').update({ with_sync = true })()
  end,

  config = function()
    local confs = require('nvim-treesitter.configs')

    confs.setup({
      ensure_installed = {
        'go',
        'javascript',
        'typescript',
        'html',
        'astro',
        'css',
        'scss',
        'lua'
      },
      ignore_install = { 'rust' }
    })
  end

}


return { TS }

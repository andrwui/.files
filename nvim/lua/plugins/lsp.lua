local mason = {
  'williamboman/mason.nvim',
  config = function()
    require('mason').setup()
  end
}

local mason_lspconfig = {
  'williamboman/mason-lspconfig.nvim',
  config = function()
    require('mason-lspconfig').setup({
      ensure_installed = {
        'gopls',
        'astro',
        'bashls',
        'cssls',
        'dockerls',
        'html',
        'ts_ls',
        'jsonls',
        'lua_ls',
        'lemminx',
      }
    })
  end
}

local lspzero = {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v4.x',
  dependencies = {
    'neovim/nvim-lspconfig',
    'onsails/lspkind.nvim'
  },
  config = function()
    local lsp_zero = require('lsp-zero')
    lsp_zero.extend_lspconfig()

    local lsp_attach = function(client, bufnr)
      if client.server_capabilities.documentFormattingProvider then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({
              async = false,
              filter = function(client)
                return client.name ~= 'ts_ls'
              end
            })
          end,
        })
      end

      lsp_zero.default_keymaps({
        buffer = bufnr,
        exclude = { 'K' }
      })
    end

    local capabilities = require('blink.cmp').get_lsp_capabilities()

    require('mason-lspconfig').setup_handlers({
      function(server_name)
        require('lspconfig')[server_name].setup({
          capabilities = capabilities,
          on_attach = lsp_attach,
        })
        require('lspconfig')['qmlls'].setup({
          cmd = { '/usr/lib/qt6/bin/qmlls', '-E' }
        })
      end,
    })
  end
}

return { mason, mason_lspconfig, lspzero }

local mason = {
  'williamboman/mason.nvim',
  config = function()
    require('mason').setup()
  end
}

local mason_lspconfig = {
  'williamboman/mason-lspconfig.nvim',
  dependencies = {
    'williamboman/mason.nvim',
    'neovim/nvim-lspconfig'
  },
  config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities()
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                async = false,
                filter = function(c)
                  return c.name ~= 'ts_ls'
                end
              })
            end
          })
        end
      end
    })

    local servers = {
      'gopls',
      'astro',
      'bashls',
      'cssls',
      'dockerls',
      'eslint',
      'html',
      'ts_ls',
      'jsonls',
      'lua_ls',
      'lemminx',
      'tailwindcss',
      'somesass_ls',
      'emmet_ls',
    }

    for _, server in ipairs(servers) do
      vim.lsp.config(server, {
        capabilities = capabilities,
      })
    end

    vim.lsp.config('eslint', {
      capabilities = capabilities,
      settings = {
        experimental = { useFlatConfig = true }
      }
    })

    vim.lsp.config('qmlls', {
      cmd = { '/usr/lib/qt6/bin/qmlls', '-E' },
      capabilities = capabilities,
    })

    require('mason-lspconfig').setup({
      ensure_installed = servers,
      automatic_enable = true,
    })

    vim.lsp.enable(vim.list_extend(servers, { 'qmlls' }))
  end
}

return { mason, mason_lspconfig }

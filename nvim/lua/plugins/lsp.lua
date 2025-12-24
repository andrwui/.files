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
                  return c.name ~= 'tsgo'
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
      'tsgo',
      'jsonls',
      'lua_ls',
      'lemminx',
      'tailwindcss',
      'somesass_ls',
      'emmet_language_server',
      'jdtls',
    }

    for _, server in ipairs(servers) do
      local opts = { capabilities = capabilities }
      if server == 'jdtls' then
        opts.settings = {
          java = {
            configuration = {
              runtimes = {
                {
                  name = 'JavaSE-1.8',
                  path = '/usr/lib/jvm/java-8-openjdk',
                  default = true
                }
              }
            }
          }
        }
      elseif server == 'eslint' then
        opts.settings = { experimental = { useFlatConfig = true } }
      elseif server == 'qmlls' then
        opts.cmd = { '/usr/lib/qt6/bin/qmlls', '-E' }
      end
      vim.lsp.config(server, opts)
    end

    require('mason-lspconfig').setup({
      ensure_installed = servers,
      automatic_enable = true,
    })

    vim.lsp.enable(vim.list_extend(servers, { 'qmlls' }))
  end
}

return { mason, mason_lspconfig }

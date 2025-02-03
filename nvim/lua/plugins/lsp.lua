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
       'sqls',
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
   'hrsh7th/cmp-nvim-lsp',
   'hrsh7th/nvim-cmp',
   'onsails/lspkind.nvim'
 },
 config = function()
   local lsp_zero = require('lsp-zero')
   lsp_zero.extend_lspconfig()

   local lsp_attach = function(client, bufnr)
     lsp_zero.default_keymaps({
       buffer = bufnr,
       exclude = { 'K' }
     })
     
     -- Disable formatting only for ts_ls
     if client.name == "tsserver" then
       client.server_capabilities.documentFormattingProvider = false
       client.server_capabilities.documentRangeFormattingProvider = false
     end

     -- Set up ESLint formatting
     if client.name == "eslint" then
       vim.api.nvim_create_autocmd("BufWritePre", {
         buffer = bufnr,
         callback = function()
           vim.cmd('EslintFixAll')
         end,
       })
     end
   end

   local cmp = require('cmp')
   cmp.setup({
     sources = {
        { name = 'nvim_lsp', max_item_count = 500 },
       { name = 'luasnip',  priority = 1000 },
       { name = 'lazydev' },
       { name = 'emmet_ls', priority = 0 }
     },
     formatting = {
       fields = { "kind", "abbr", "menu" },
       expandable_indicator = true,
       format = function(entry, vim_item)
         vim_item.menu = ({
           nvim_lsp = '[LSP]',
           luasnip = '[Snippet]',
           lazydev = '[Lazy]'
         })[entry.source.name]
         return vim_item
       end
     },
     mapping = {
       ['<CR>'] = cmp.mapping.confirm({ select = true }),
       ['<C-Space>'] = cmp.mapping.complete(),
       ['<Up>'] = cmp.mapping.select_prev_item(),
       ['<Down>'] = cmp.mapping.select_next_item(),
     }
   })

   local capabilities = require('cmp_nvim_lsp').default_capabilities()
   require('mason-lspconfig').setup_handlers({
     function(server_name)
       require('lspconfig')[server_name].setup({
         capabilities = capabilities,
         on_attach = lsp_attach,
       })
     end,
   })
 end
}

return { mason, mason_lspconfig, lspzero }

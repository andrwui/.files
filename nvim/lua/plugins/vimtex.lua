local vimtex = {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_mappings_enabled = 0
  end
}

return { vimtex }

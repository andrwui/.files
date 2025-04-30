local spider = {
  "chrisgrieser/nvim-spider",
  lazy = true,
  config = function()
    require("spider").setup {
      skipInsignificantPunctuation = false,
      consistentOperatorPending = false,
      subwordMovement = true,
      customPatterns = {},
    }
  end
}

return { spider }

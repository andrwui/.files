local indent_blankline = {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    config = function()
	require('ibl').setup()
    end,
}




return {indent_blankline}

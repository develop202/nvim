return {
	{
    --"folke/tokyonight.nvim",
		--"morhetz/gruvbox",
		"ellisonleao/gruvbox.nvim",
		event = "VimEnter",
		--"sainnhe/gruvbox-material",
		dependencies = {
			"nvim-lualine/lualine.nvim",
			"nvim-tree/nvim-web-devicons",
			"utilyre/barbecue.nvim",
			"SmiteshP/nvim-navic",
		},
		config = function()
    --vim.cmd[[colorscheme tokyonight-storm]]
		vim.cmd[[colorscheme gruvbox]]
		require('lualine').setup({
			options = {
				theme = 'gruvbox'
			},
		})
		require('barbecue').setup {
			theme = 'gruvbox'
		}
		end
	},
}
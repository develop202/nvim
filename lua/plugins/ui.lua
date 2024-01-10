return {
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		config = true,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = true
	},
	{
		"goolord/alpha-nvim",
		config = function()
		require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
		end
	},
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		config = function()
		require('illuminate').configure({
			vim.api.nvim_set_hl(0, "IlluminatedWordText", {
				link = "Visual"
			}),
			vim.api.nvim_set_hl(0, "IlluminatedWordRead", {
				link = "Visual"
			}),
			vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {
				link = "Visual"
			})

		})
		end
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = {
			"BufReadPost", "BufNewFile"
		},
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = {
				enabled = false
			},
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
		},
		main = "ibl",
	},
	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = {
			"BufReadPost", "BufNewFile"
		},
		opts = {
-- symbol = "▏",
			symbol = "│",
			options = {
				try_as_border = true
			},
		},
		init = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
			callback = function()
			vim.b.miniindentscope_disable = true
			end,
		})
		end,
	}
}
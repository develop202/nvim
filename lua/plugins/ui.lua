return {
	{
		"RRethy/vim-illuminate",
		event = "VeryLazy",
		config = function()
			require("illuminate").configure({
				vim.api.nvim_set_hl(0, "IlluminatedWordText", {
					link = "Visual",
				}),
				vim.api.nvim_set_hl(0, "IlluminatedWordRead", {
					link = "Visual",
				}),
				vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {
					link = "Visual",
				}),
			})
		end,
	},
	-- {
	--   "NvChad/nvim-colorizer.lua",
	--   event = { "BufReadPost", "BufNewFile" },
	--   cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
	--   -- opts = { user_default_options = { names = false } },
	--   config = function()
	--     -- require 'colorizer'.setup()
	--     -- Attach to buffer
	--     require("colorizer").attach_to_buffer(0, { mode = "background", css = true })
	--   end
	-- },
	{
		"brenoprata10/nvim-highlight-colors",
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			-- Ensure termguicolors is enabled if not already
			vim.opt.termguicolors = true
			require("nvim-highlight-colors").setup({})
		end,
	},
	{
		"hiphish/rainbow-delimiters.nvim",
		event = { "LazyFile" }, --,"BufReadPost", "BufNewFile" },
		config = function()
			require("rainbow-delimiters.setup").setup({})
		end,
		-- config = function()
		--   -- require("rainbow-delimiters.setup").setup({})
		--   -- This module contains a number of default definitions
		--   local rainbow_delimiters = require 'rainbow-delimiters'
		--
		--   ---@type rainbow_delimiters.config
		--   vim.g.rainbow_delimiters = {
		--     strategy = {
		--       [''] = rainbow_delimiters.strategy['global'],
		--       vim = rainbow_delimiters.strategy['local'],
		--     },
		--     query = {
		--       [''] = 'rainbow-delimiters',
		--       lua = 'rainbow-blocks',
		--     },
		--     priority = {
		--       [''] = 110,
		--       lua = 210,
		--     },
		--     highlight = {
		--       'RainbowDelimiterRed',
		--       'RainbowDelimiterYellow',
		--       'RainbowDelimiterBlue',
		--       'RainbowDelimiterOrange',
		--       'RainbowDelimiterGreen',
		--       'RainbowDelimiterViolet',
		--       'RainbowDelimiterCyan',
		--     },
		--   }
		-- end
	},
	-- {
	-- 	"tamton-aquib/duck.nvim",
	-- 	config = function()
	-- 		vim.keymap.set("n", "<leader>du", function()
	-- 			require("duck").hatch()
	-- 		end, {})
	-- 		vim.keymap.set("n", "<leader>dk", function()
	-- 			require("duck").cook()
	-- 		end, {})
	-- 		vim.keymap.set("n", "<leader>dl", function()
	-- 			require("duck").cook_all()
	-- 		end, {})
	-- 	end,
	-- },
	{
		"akinsho/bufferline.nvim",
		opts = {
			options = {
				style_preset = require("bufferline").style_preset.no_italic,
			},
		},
	},
}

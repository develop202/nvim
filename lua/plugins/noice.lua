return {
	"folke/noice.nvim",
	event = "UIEnter",
	opts = {},
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
	require("noice").setup({
		presets = {
			bottom_search = true
		},
		views = {
			cmdline_popup = {
				position = {
					row = 5,
					col = "50%",
				},
				size = {
					width = '60%',
					height = "auto",
				},
			},
			popupmenu = {
				relative = "editor",
				position = {
					row = 8,
					col = "50%",
				},
				size = {
					width = '65%',
					height = 5,
				},
				border = {
					style = "rounded",
					padding = {
						0, 1
					}
				}
			}
		},
	})
	end,
	keys = {
		{
			"<Esc>", function() vim.cmd.Noice("dismiss") end, desc = "󰎟 Clear Notifications"
		},
		{
			"<D-0>",
			function()
			vim.cmd.Noice("dismiss")
			vim.cmd.Noice("history")
			end,
			mode = {
				"n", "x", "i"
			},
			desc = "󰎟 Notification Log",
		},
	},
}
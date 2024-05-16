return {
	"folke/noice.nvim",
	opts = {
		presets = {
			command_palette = false,
		},
		cmdline = {
			format = {
				lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
				calculator = { pattern = "^=", icon = " ", lang = "vimnormal" },
			},
		},
		views = {
			cmdline_popup = {
				position = {
					row = 5,
					col = "50%",
				},
				size = {
					width = "60%",
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
					width = "65%",
					height = 5,
				},
				border = {
					style = "rounded",
					padding = {
						0,
						1,
					},
				},
			},
		},
	},
	keys = {
		{
			"<Esc>",
			function()
				vim.cmd.Noice("dismiss")
			end,
			desc = "Clear Notifications",
		},
		{
			"<D-0>",
			function()
				vim.cmd.Noice("dismiss")
				vim.cmd.Noice("history")
			end,
			mode = {
				"n",
				"x",
				"i",
			},
			desc = "Notification Log",
		},
	},
}

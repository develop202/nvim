return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = {
		"DBUI",
		"DBUIToggle",
		"DBUIAddConnection",
		"DBUIFindBuffer",
	},
	init = function()
		-- Your DBUI configuration
		vim.g.db_ui_icons = {
			expanded = {
				db = "▾" .. " 󰆼 ",
				buffers = "▾" .. "  ",
				saved_queries = "▾" .. "  ",
				schemas = "▾" .. "  ",
				schema = "▾" .. " 󰙅 ",
				tables = "▾" .. " 󰓱 ",
				table = "▾" .. "  ",
			},
			collapsed = {
				db = "▸" .. " 󰆼 ",
				buffers = "▸" .. "  ",
				saved_queries = "▸" .. "  ",
				schemas = "▸" .. "  ",
				schema = "▸" .. " 󰙅 ",
				tables = "▸" .. " 󰓱 ",
				table = "▸" .. "  ",
			},
			saved_query = "   ",
			new_query = "  󰓰 ",
			tables = "  󰓫 ",
			buffers = "   ",
			add_connection = "  󰆺 ",
			connection_ok = "✓",
			connection_error = "✕",
		}
		vim.g.db_ui_execute_on_save = 0
		vim.g.db_ui_use_nerd_fonts = 1
	end,
}

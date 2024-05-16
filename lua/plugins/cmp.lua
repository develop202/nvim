return {
	{
		-- "onsails/lspkind.nvim",
		"hrsh7th/nvim-cmp",
		opts = {
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(_, item)
					local icons = require("lazyvim.config").icons.kinds
					icons = {
						Array = " ",
						Boolean = " ",
						Class = " ",
						-- Codeium       = "󰘦 ",
						Color = " ",
						Control = " ",
						Collapsed = " ",
						Constant = " ",
						Constructor = " ",
						-- Copilot       = " ",
						Enum = " ",
						EnumMember = " ",
						Event = " ",
						Field = " ",
						File = " ",
						Folder = " ",
						Function = "󰊕 ",
						Interface = " ",
						Key = "󰌋 ",
						Keyword = " ",
						Method = " ",
						Module = " ",
						Namespace = " ",
						Null = " ",
						Number = "󰎠 ",
						Object = " ",
						Operator = " ",
						Package = " ",
						Property = " ",
						Reference = " ",
						Snippet = " ",
						String = " ",
						Struct = " ",
						TabNine = "󰏚 ",
						Text = "󰉿 ",
						TypeParameter = " ",
						Unit = " ",
						Value = " ",
						Variable = " ",
					}

					if vim.bo.filetype == "sql" or vim.bo.filetype == "mysql" then
						icons.Text = " "
					end
					if icons[item.kind] then
						item.kind = icons[item.kind]
					end
					return item
				end,
			},
		},
	},
	{
		"hrsh7th/cmp-cmdline",
		event = "InsertEnter",
		config = function()
			local cmp = require("cmp")
			cmp.setup.cmdline("/", {
				completion = { completeopt = "menu,menuone,noselect" },
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{
						name = "buffer",
					},
				},
			})
			-- cmp.setup.cmdline(':', {
			--   completion = { completeopt = 'menu,menuone,noselect' },
			--   mapping = cmp.mapping.preset.cmdline(),
			--   sources = cmp.config.sources({
			--     {
			--       name = 'path'
			--     },
			--     {
			--       name = 'cmdline'
			--     }
			--   })
			-- })
		end,
	},
}

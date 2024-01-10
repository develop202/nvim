return {
	"hrsh7th/nvim-cmp",
	event = {
		"BufReadPost", "BufNewFile"
	},
	dependencies = {
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
--	"hrsh7th/cmp-nvim-lsp-signature-help",
		"saadparwaiz1/cmp_luasnip",
		"onsails/lspkind.nvim",
		{
			"saadparwaiz1/cmp_luasnip",
			dependencies = {
				"L3MON4D3/LuaSnip",
				dependencies = {
					"rafamadriz/friendly-snippets",
				}
			}
		},
	},
	config = function()


	require('lspkind').init({
-- DEPRECATED (use mode instead): enables text annotations
--
-- default: true
-- with_text = true,

-- defines how annotations are shown
-- default: symbol
-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
		mode = 'symbol_text',

-- default symbol map
-- can be either 'default' (requires nerd-fonts font) or
-- 'codicons' for codicon preset (requires vscode-codicons font)
--
-- default: 'default'
		preset = 'codicons',

-- override preset symbols
--
-- default: {}
		symbol_map = {
			Text = "󰉿",
			Method = "󰆧",
			Function = "󰊕",
			Constructor = "",
			Field = "󰜢",
			Variable = "󰀫",
			Class = "󰠱",
			Interface = "",
			Module = "",
			Property = "󰜢",
			Unit = "󰑭",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "󰈇",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "󰙅",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "",
		},
	})


	local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
	end
	require("luasnip.loaders.from_vscode").lazy_load()
	local luasnip = require("luasnip")
	local cmp = require 'cmp'

	local lspkind = require('lspkind')
-- If you want insert `(` after select function or method item
	local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	local cmp = require('cmp')
	cmp.event:on(
		'confirm_done',
		cmp_autopairs.on_confirm_done()
	)


	cmp.setup {


		formatting = {
			format = lspkind.cmp_format({
				mode = 'symbol', -- show only symbol annotations
				maxwidth = 10, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
				ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

-- The function below will be called before any actual modifications from lspkind
-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
				before = function (entry, vim_item)

				return vim_item
				end
			})
		},


		snippet = {
			expand = function(args)
			require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			end,
		},
		sources = cmp.config.sources {
			{
				name = 'nvim_lsp'
			},
			{
				name = 'path'
			},
			{
				name = 'luasnip'
			},
			{
				name = "buffer"
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
				cmp.select_next_item()
-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
-- they way you will only jump inside the snippet region
				elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
				elseif has_words_before() then
				cmp.complete()
				else
					fallback()
				end
				end, {
					"i", "s"
				}),

			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
				cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
				else
					fallback()
				end
				end, {
					"i", "s"
				}),
			['<CR>'] = cmp.mapping.confirm({
				select = true
			}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		},
		experimental = {
			ghost_text = true,
		}
	}

	cmp.setup.cmdline('/', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{
				name = 'buffer'
			},
		}
	})

	cmp.setup.cmdline(':', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{
				name = 'path'
			},
			{
				name = 'cmdline'
			}
		})
	})
	end,
}
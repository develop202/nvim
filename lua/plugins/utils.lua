return {
	{
		"rhysd/accelerated-jk",
		keys = {
			{
				"j", "<Plug>(accelerated_jk_gj)"
			},
			{
				"k", "<Plug>(accelerated_jk_gk)"
			},
		},
	},
	{
		"folke/persistence.nvim",
		keys = {
			{
				"<leader>qs", [[<cmd>lua require("persistence").load()<cr>]]
			},
			{
				"<leader>ql", [[<cmd>lua require("persistence").load({ last = true})<cr>]]
			},
			{
				"<leader>qd", [[<cmd>lua require("persistence").stop()<cr>]]
			},
		},
		config = true,
	},
	{
		"windwp/nvim-autopairs",
		event = "BufNewFile",
		opts = {
			enable_check_bracket_line = false,
		},
	},
	{
		"ethanholz/nvim-lastplace",
		config = true,
	},
	{
		"folke/flash.nvim",
		keys = {
			{
				"s",
				mode = {
					"n", "x", "o"
				},
				function()
				require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"SS",
				mode = {
					"n", "o", "x"
				},
				function()
				require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
				require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = {
					"o", "x"
				},
				function()
				require("flash").treesitter_search()
				end,
				desc = "Flash Treesitter Search",
			},
			{
				"<c-s>",
				mode = {
					"c"
				},
				function()
				require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
		config = true
	},
	{
		"kamykn/spelunker.vim",
		event = "VeryLazy",
		config = function()
		vim.g.spelunker_check_type = 2
		end
	},
	{
		"ellisonleao/glow.nvim",
		event = "VeryLazy",
		config = true,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>e",
				"<cmd>Neotree toggle<CR>",
				desc = "Open the neo-tree",
				mode = {
					"n", "v"
				}
			}
		},
		config = function()
		local renderer = require "neo-tree.ui.renderer"

-- Expand a node and load filesystem info if needed.
		local function open_dir(state, dir_node)
		local fs = require "neo-tree.sources.filesystem"
		fs.toggle_directory(state, dir_node, nil, true, false)
		end

-- Expand a node and all its children, optionally stopping at max_depth.
		local function recursive_open(state, node, max_depth)
		local max_depth_reached = 1
		local stack = {
			node
		}
		while next(stack) ~= nil do
		node = table.remove(stack)
		if node.type == "directory" and not node:is_expanded() then
		open_dir(state, node)
		end

		local depth = node:get_depth()
		max_depth_reached = math.max(depth, max_depth_reached)

		if not max_depth or depth < max_depth - 1 then
		local children = state.tree:get_nodes(node:get_id())
		for _, v in ipairs(children) do
		table.insert(stack, v)
		end
		end
		end

		return max_depth_reached
		end

--- Open the fold under the cursor, recursing if count is given.
		local function neotree_zo(state, open_all)
		local node = state.tree:get_node()

		if open_all then
		recursive_open(state, node)
		else
			recursive_open(state, node, node:get_depth() + vim.v.count1)
		end

		renderer.redraw(state)
		end

--- Recursively open the current folder and all folders it contains.
		local function neotree_zO(state)
		neotree_zo(state, true)
		end
		require("neo-tree").setup {
			filesystem = {
				window = {
					mappings = {
						["z"] = "none",
						["zo"] = neotree_zo,
						["<tab>"] = neotree_zO,
					},
				},
			},
		}

		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = true,
	},
	{
		'echasnovski/mini.ai',
		event = "VeryLazy",
		config = true,
	},
	{
		"echasnovski/mini.comment",
		event = "VeryLazy",
		config = true,
	},
	{
		"s1n7ax/nvim-window-picker",
		opts = {
			filter_rules = {
				include_current_win = true,
				bo = {
					filetype = {
						"fidget", "neo-tree"
					}
				}
			}
		},
		keys = {
			{
				"<c-w>p",
				function()
				local window_number = require('window-picker').pick_window()
				if window_number then vim.api.nvim_set_current_win(window_number) end
				end,
			}
		}
	},
}
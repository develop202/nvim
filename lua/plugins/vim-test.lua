return {
	"vim-test/vim-test",
	event = {
		"BufReadPost", "BufNewFile"
	},
	vim.api.nvim_set_keymap('n', '<Leader>t', '<cmd>TestNearest<CR>', {
		silent = true
	}),
	vim.api.nvim_set_keymap('n', '<Leader>T', '<cmd>TestFile<CR>', {
		silent = true
	}),
	vim.api.nvim_set_keymap('n', '<Leader>a', '<cmd>TestSuite<CR>', {
		silent = true
	}),
	vim.api.nvim_set_keymap('n', '<Leader>l', '<cmd>TestLast<CR>', {
		silent = true
	}),
	vim.api.nvim_set_keymap('n', '<Leader>g', '<cmd>TestVisit<CR>', {
		silent = true
	})
}
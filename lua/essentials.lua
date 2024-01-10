local option = vim.opt
local buffer = vim.b
local global = vim.g

-- Globol Settings --
option.showmode = false
option.backspace = {
	"indent", "eol", "start"
}
option.tabstop = 2
option.shiftwidth = 2
option.expandtab = true
option.shiftround = true
option.autoindent = true
option.smartindent = true
option.number = true
option.relativenumber = true
option.wildmenu = true
option.hlsearch = false
option.ignorecase = true
option.smartcase = true
option.completeopt = {
	"menuone", "noselect"
}
option.cursorline = true
option.termguicolors = true
option.signcolumn = "yes"
option.autoread = true
option.title = true
option.swapfile = false
option.backup = false
option.updatetime = 50
option.mouse = "a"
option.undofile = true
option.undodir = vim.fn.expand('$HOME/.local/share/nvim/undo')
option.exrc = true
option.wrap = true
option.splitright = true

-- vim.opt.foldmethod = "indent"
-- vim.opt.foldmethod = "manual"
-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr='nvim_treesitter#foldexpr()'
-- vim.opt.foldlevelstart = 99
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Buffer Settings --
buffer.fileenconding = "utf-8"

-- Global Settings --
global.mapleader = " "

vim.keymap.set("n", "<Tab>", "<cmd>bNext<CR>")
vim.keymap.set("n", "<leader>bc", "<cmd>bd<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({
	"v", "n"
}, "<leader>y", "\"+y")

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

vim.keymap.set("n" , "<C-left>", "<C-w><")
vim.keymap.set("n" , "<C-right>", "<C-w>>")
vim.keymap.set("n" , "<C-up>", "<C-w>+")
vim.keymap.set("n" , "<C-down>", "<C-w>-")

vim.keymap.set("n" , "<A-left>", "zH")
vim.keymap.set("n" , "<A-right>", "zL")

vim.keymap.set("n" , "ca", "<cmd>bufdo bd<CR>")

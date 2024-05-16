-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lsp快捷键
vim.keymap.set("n", "<space>x", vim.diagnostic.open_float, { desc = "Displays the Prompt message" })
vim.keymap.set("n", "<space>f", function()
	if
		vim.bo.filetype == "sh"
		or vim.bo.filetype == "yaml"
		or vim.bo.filetype == "sql"
		or vim.bo.filetype == "mysql"
		or vim.bo.filetype == "python"
		or vim.bo.filetype == "lua"
		or vim.bo.filetype == "luau"
	then
		LazyVim.format({ force = true })
		return
	end
	vim.lsp.buf.format({
		async = true,
		filter = function(client)
			if client.name == "tsserver" and vim.bo.filetype == "vue" then
				-- print("ok")
				return client.name ~= "tsserver"
			end
			-- print(client.name .. "格式化成功")
			return client.name == client.name
			-- return client.name == "null-ls"
		end,
	})
end, { desc = "[F]ormat code" })

local opts = { noremap = true, silent = true }
-- 大纲
vim.keymap.set("n", "<leader>ol", "<cmd>Outline<CR>", { desc = "文件大纲" })
--生成文档注释
vim.api.nvim_set_keymap(
	"n",
	"<Leader>fn",
	"<cmd>lua require('neogen').generate()<CR>",
	{ noremap = true, silent = true, desc = "生成文档注释" }
)

vim.keymap.set("n", "<Tab>", "<cmd>bNext<CR>", { desc = "下一个buffer" })
vim.keymap.set("n", "<leader><Tab>", "<cmd>bnext<cr>", { desc = "上一个buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>bd<CR>", { desc = "关闭当前buffer" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({
	"v",
	"n",
}, "<leader>y", '"+y', { desc = "复制到系统剪切板" })

-- 离开插入模式自动保存
-- vim.api.nvim_create_autocmd({ "InsertLeave" }, {
--   callback = function()
--     vim.fn.execute("silent! write")
--     vim.notify("Autosaved!", vim.log.levels.INFO, {})
--   end,
-- })
--窗口大小
vim.keymap.set("n", "<C-left>", "<C-w><")
vim.keymap.set("n", "<C-right>", "<C-w>>")
vim.keymap.set("n", "<C-up>", "<C-w>+")
vim.keymap.set("n", "<C-down>", "<C-w>-")
--左右滚动代码
vim.keymap.set("n", "<A-left>", "zH")
vim.keymap.set("n", "<A-right>", "zL")
--关闭所有buffer
vim.keymap.set("n", "ca", "<cmd>bufdo bd<CR>")
--vim-test测试插件
vim.api.nvim_set_keymap("n", "<Leader>t", "<cmd>TestNearest<CR>", {
	silent = true,
})
vim.api.nvim_set_keymap("n", "<Leader>T", "<cmd>TestFile<CR>", {
	silent = true,
})
vim.api.nvim_set_keymap("n", "<Leader>a", "<cmd>TestSuite<CR>", {
	silent = true,
})
vim.api.nvim_set_keymap("n", "<Leader>l", "<cmd>TestLast<CR>", {
	silent = true,
})
vim.api.nvim_set_keymap("n", "<Leader>g", "<cmd>TestVisit<CR>", {
	silent = true,
})
--trouble.nvim
vim.keymap.set("n", "<leader>xx", function()
	require("trouble").open()
end)
vim.keymap.set("n", "<leader>xw", function()
	require("trouble").open("workspace_diagnostics")
end)
vim.keymap.set("n", "<leader>xd", function()
	require("trouble").open("document_diagnostics")
end)
vim.keymap.set("n", "<leader>xq", function()
	require("trouble").open("quickfix")
end)
vim.keymap.set("n", "<leader>xl", function()
	require("trouble").open("loclist")
end)
vim.keymap.set("n", "gR", function()
	require("trouble").open("lsp_references")
end)

-- Key bindings
local map = vim.api.nvim_set_keymap
-- Run tests
map("n", "<leader>nt", "<cmd>lua require('neotest').run.run()<CR>", opts)
-- Run nearest test
map("n", "<leader>nf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", opts)
-- Run last test
map("n", "<leader>nl", "<cmd>lua require('neotest').run.run_last()<CR>", opts)
-- Debug last test
map("n", "<leader>nL", "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<CR>", opts)
-- Run tests in watch mode
map("n", "<leader>nw", "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<CR>", opts)
-- out window
map("n", "<leader>no", "<cmd>lua require('neotest').output.open({ enter = true })<CR>", opts)
-- show all test
map("n", "<leader>na", "<cmd>lua require('neotest').summary.open()<CR>", opts)

-- dap按键映射
vim.keymap.set("n", "<Leader>dd", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<Leader>sv", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<Leader>si", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<Leader>so", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<Leader>B", function()
	require("dap").set_breakpoint()
end)
vim.keymap.set("n", "<Leader>lp", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end)
vim.keymap.set("n", "<Leader>dr", function()
	require("dap").repl.open()
end)
vim.keymap.set("n", "<Leader>dl", function()
	require("dap").run_last()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
	require("dap.ui.widgets").hover()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
	require("dap.ui.widgets").preview()
end)
vim.keymap.set("n", "<Leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end)
vim.keymap.set("n", "<Leader>ds", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end)
vim.keymap.set("n", "<space>cp", function()
	local dapui = require("dapui")
	dapui.close()
end, { desc = "关闭dap-UI" })
-- Java测试结果
vim.keymap.set(
	"n",
	"<Leader>jr",
	"<cmd>lua require('dapui').toggle(2)<CR>",
	{ desc = "Java测试结果" }
)
-- vim.keymap.set(
-- 	"n",
-- 	"<Leader>jt",
-- 	-- "<cmd>lua require('dapui').toggle({elements = {id = 'console',size = 1,},position = 'bottom',size = 10})<CR>",
-- 	function()
-- 		require("dapui").toggle("console")
-- 	end,
-- 	{ desc = "Java终端测试结果" }
-- )

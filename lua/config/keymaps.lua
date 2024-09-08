-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lsp快捷键
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "显示诊断消息" })
-- vim.keymap.set("n", "<leader>fd", function()
--   if
--     vim.bo.filetype == "sh"
--     or vim.bo.filetype == "yaml"
--     or vim.bo.filetype == "sql"
--     or vim.bo.filetype == "mysql"
--     or vim.bo.filetype == "python"
--     or vim.bo.filetype == "lua"
--     or vim.bo.filetype == "luau"
--   then
--     LazyVim.format({ force = true })
--     return
--   end
--   vim.lsp.buf.format({
--     async = true,
--     filter = function(client)
--       if client.name == "tsserver" and vim.bo.filetype == "vue" then
--         -- print("ok")
--         return client.name ~= "tsserver"
--       end
--       -- print(client.name .. "格式化成功")
--       return client.name == client.name
--       -- return client.name == "null-ls"
--     end,
--   })
-- end, { desc = "格式化文档" })
vim.keymap.set("n", "<leader>fd", function()
  LazyVim.format({ force = true })
end, { desc = "格式化文档" })
-- local opts = { noremap = true, silent = true }
-- 大纲
vim.keymap.set("n", "<leader>ol", "<cmd>Outline<CR>", { desc = "文件大纲" })
--生成文档注释
vim.api.nvim_set_keymap(
  "n",
  "<leader>fn",
  "<cmd>lua require('neogen').generate()<CR>",
  { noremap = true, silent = true, desc = "生成文档注释" }
)

vim.keymap.set("n", "<Tab>", "<cmd>bNext<CR>", { desc = "下一个buffer" })
vim.keymap.set("n", "<leader><Tab>", "<cmd>bnext<cr>", { desc = "上一个buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>bd<CR>", { desc = "关闭当前buffer" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "将选中的代码块与下一行交换位置" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "将选中的代码块与上一行交换位置" })

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
vim.keymap.set("n", "<C-left>", "<C-w><", { desc = "向左调整窗口" })
vim.keymap.set("n", "<C-right>", "<C-w>>", { desc = "向右调整窗口" })
vim.keymap.set("n", "<C-up>", "<C-w>+", { desc = "向上调整窗口" })
vim.keymap.set("n", "<C-down>", "<C-w>-", { desc = "向下调整窗口" })
--左右滚动代码
vim.keymap.set("n", "<A-left>", "zH", { desc = "向左滚动代码" })
vim.keymap.set("n", "<A-right>", "zL", { desc = "向右滚动代码" })
-- 上下滚动代码
vim.keymap.set("n", "<A-up>", "10k", { desc = "向上滚动代码" })
vim.keymap.set("n", "<A-down>", "10j", { desc = "向下滚动代码" })
--关闭所有buffer
vim.keymap.set("n", "ca", "<cmd>bufdo bd<CR>", { desc = "关闭所有buffer" })
--vim-test测试插件
vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>TestNearest<CR>", {
  silent = true,
  desc = "运行光标所在的测试",
})
vim.api.nvim_set_keymap("n", "<leader>T", "<cmd>TestFile<CR>", {
  silent = true,
  desc = "运行测试文件",
})
vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>TestSuite<CR>", {
  silent = true,
  desc = "TestSuite",
})
vim.api.nvim_set_keymap("n", "<leader>lt", "<cmd>TestLast<CR>", {
  silent = true,
  desc = "运行文件最后一个测试",
})
vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>TestVisit<CR>", {
  silent = true,
  desc = "TestVisit",
})
--trouble.nvim
vim.keymap.set("n", "<leader>xo", function()
  require("trouble").open()
end, { desc = "trouble open" })
vim.keymap.set("n", "<leader>xw", function()
  require("trouble").open("workspace_diagnostics")
end, { desc = "工作区诊断(Trouble)" })
vim.keymap.set("n", "<leader>xd", function()
  require("trouble").open("document_diagnostics")
end, { desc = "文件诊断(Trouble)" })
vim.keymap.set("n", "<leader>xq", function()
  require("trouble").open("quickfix")
end, { desc = "快速修复列表(Trouble)" })
vim.keymap.set("n", "<leader>xl", function()
  require("trouble").open("loclist")
end, { desc = "位置列表(Trouble)" })
vim.keymap.set("n", "gR", function()
  require("trouble").open("lsp_references")
end, { desc = "lsp引用(Trouble)" })

-- Key bindings
local map = vim.api.nvim_set_keymap
-- Run tests
map(
  "n",
  "<leader>nt",
  "<cmd>lua require('neotest').run.run()<CR>",
  { noremap = true, silent = true, desc = "neotest运行光标处测试" }
)
-- Run nearest test
map(
  "n",
  "<leader>nf",
  "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
  { noremap = true, silent = true, desc = "neotest运行当前文件" }
)
-- Run last test
map(
  "n",
  "<leader>nl",
  "<cmd>lua require('neotest').run.run_last()<CR>",
  { noremap = true, silent = true, desc = "neotest运行最后一个测试" }
)
-- Debug last test
map(
  "n",
  "<leader>nL",
  "<cmd>lua require('neotest').run.run_last({ strategy = 'dap' })<CR>",
  { noremap = true, silent = true, desc = "neotest调试最后一个测试" }
)
-- Run tests in watch mode
map(
  "n",
  "<leader>nw",
  "<cmd>lua require('neotest').run.run({ jestCommand = 'jest --watch ' })<CR>",
  { noremap = true, silent = true, desc = "neotest在监视模式下运行测试" }
)
-- out window
map(
  "n",
  "<leader>no",
  "<cmd>lua require('neotest').output.open({ enter = true })<CR>",
  { noremap = true, silent = true, desc = "neotest输出窗口" }
)
-- show all test
map(
  "n",
  "<leader>na",
  "<cmd>lua require('neotest').summary.open()<CR>",
  { noremap = true, silent = true, desc = "neotest当前文件所有测试" }
)

-- dap按键映射
vim.keymap.set("n", "<leader>dd", function()
  require("dap").continue()
end, { desc = "开始调试" })
vim.keymap.set("n", "<leader>sv", function()
  require("dap").step_over()
end, { desc = "步过" })
vim.keymap.set("n", "<leader>si", function()
  require("dap").step_into()
end, { desc = "步入" })
vim.keymap.set("n", "<leader>so", function()
  require("dap").step_out()
end, { desc = "步出" })
vim.keymap.set("n", "<leader>b", function()
  require("dap").toggle_breakpoint()
end, { desc = "设置/删除断点" })
vim.keymap.set("n", "<leader>B", function()
  require("dap").set_breakpoint()
end, { desc = "设置断点" })
vim.keymap.set("n", "<leader>lp", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "设置断点及其描述" })
vim.keymap.set("n", "<leader>dr", function()
  require("dap").repl.open()
end, { desc = "打开repl(附带按键的窗口)" })
vim.keymap.set("n", "<leader>dl", function()
  require("dap").run_last()
end, { desc = "运行最后一个" })
vim.keymap.set({ "n", "v" }, "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "悬停" })
vim.keymap.set({ "n", "v" }, "<leader>dp", function()
  require("dap.ui.widgets").preview()
end, { desc = "预览" })
vim.keymap.set("n", "<leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, { desc = "线程和堆栈帧(悬浮窗)" })
vim.keymap.set("n", "<leader>ds", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, { desc = "变量作用域(悬浮窗)" })
vim.keymap.set("n", "<leader>cp", function()
  local dapui = require("dapui")
  dapui.close()
end, { desc = "关闭dap-UI" })
vim.keymap.set("n", "<leader>op", function()
  local dapui = require("dapui")
  dapui.open()
end, { desc = "打开dap-UI" })
-- Java测试结果
vim.keymap.set("n", "<leader>jr", "<cmd>lua require('dapui').toggle(2)<CR>", { desc = "Java测试结果" })
-- vim.keymap.set(
--   "n",
--   "<leader>jt",
--   -- "<cmd>lua require('dapui').toggle({elements = {id = 'console',size = 1,},position = 'bottom',size = 10})<CR>",
--   function()
--     require("dapui").toggle("console")
--   end,
--   { desc = "Java终端测试结果" }
-- )
-- telescope快捷键
vim.keymap.set(
  "n",
  "<leader>wf",
  "<cmd>lua require('telescope.builtin').find_files()<cr>",
  { desc = "查找工作区文件" }
)
vim.keymap.set(
  "n",
  "<leader>lg",
  "<cmd>lua require('telescope.builtin').live_grep()<cr>",
  { desc = "查找工作区字词" }
)

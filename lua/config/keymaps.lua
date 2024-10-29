-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lsp快捷键
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "显示诊断消息" })

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
vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>TestVisit<CR>", {
  silent = true,
  desc = "TestVisit",
})

-- dap按键映射
vim.keymap.set({ "n", "v" }, "<leader>dh", function()
  require("dap.ui.widgets").hover()
end, { desc = "悬停" })
vim.keymap.set({ "n", "v" }, "<leader>dp", function()
  require("dap.ui.widgets").preview()
end, { desc = "预览" })

-- Java测试结果
vim.keymap.set("n", "<leader>os", "<cmd>lua require('dapui').toggle(2)<CR>", { desc = "Java测试结果" })

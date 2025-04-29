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
vim.keymap.set("n", "<leader>ol", function()
  if not vim.g.outline_is_loaded then
    -- 去空格
    OwnUtil.utils.termux_change_file_line(
      vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
      867,
      "    line = line .. node.name"
    )
    -- 去高亮
    OwnUtil.utils.termux_change_file_line(
      vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
      881,
      "    node.prefix_length = hl_end"
    )
    -- 描述outline已被使用
    vim.g.outline_is_loaded = 1
  end

  -- 显示大纲
  vim.cmd("Outline")
end, { desc = "文件大纲" })

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

-- 删除已保存会话，需要先打开会话再删除
vim.keymap.set("n", "<leader>qD", function()
  local M = require("persistence")
  local sfile = M.current()
  if sfile and (vim.uv or vim.loop).fs_stat(sfile) ~= 0 then
    M.stop()
    vim.fn.system("rm " .. vim.fn.fnameescape(sfile))
  end
end, { desc = "Delete Current Session" })

-- 打开当前项目的TODO列表
-- vim.keymap.set("n", "<leader>xd", function()
--   vim.cmd("TodoTelescope cwd=" .. LazyVim.root.detect({ all = true })[1].paths[1])
-- end, { desc = "打开当前项目的TODO列表" })

-- JavaProject
vim.keymap.set("n", "<leader>jp", "<cmd>JavaProject<CR>", { desc = "Java Projects" })

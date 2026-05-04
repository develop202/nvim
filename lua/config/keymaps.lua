-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lsp快捷键
vim.keymap.set("n", "<leader>m", vim.diagnostic.open_float, { desc = "显示诊断消息" })

vim.keymap.set("n", "<leader>fd", function()
  if vim.o.filetype == "groovy" then
    LazyVim.format({ force = true })
  end
  LazyVim.format({ force = true })
end, { desc = "格式化文档" })
-- local opts = { noremap = true, silent = true }
-- 大纲
vim.keymap.set("n", "<leader>ol", function()
  if not vim.g.outline_is_loaded then
    -- 去空格
    OwnUtil.utils.termux_change_file_line(
      vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
      905,
      "    line = line .. node.name"
    )
    -- 去高亮
    OwnUtil.utils.termux_change_file_line(
      vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
      919,
      "    node.prefix_length = hl_end"
    )

    -- 处理vue lsp的特殊情况
    OwnUtil.utils.termux_change_file_line(
      vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/providers/nvim-lsp.lua",
      62,
      "  if vim.o.filetype == 'vue' and use_client.name =='vtsls' and #clients >=2 then use_client = clients[2] end"
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
vim.keymap.set("n", "<A-left>", vim.opt.wrap and "10h" or "zH", { desc = "向左滚动代码" })
vim.keymap.set("n", "<A-right>", vim.opt.wrap and "10l" or "zL", { desc = "向右滚动代码" })
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

-- 打开当前项目的TODO列表
-- vim.keymap.set("n", "<leader>xd", function()
--   vim.cmd("TodoTelescope cwd=" .. LazyVim.root.detect({ all = true })[1].paths[1])
-- end, { desc = "打开当前项目的TODO列表" })

-- 当mason无法安装lsp,本地可以安装,但显示需要更新时，可以去除更新显示
vim.keymap.set("n", "<leader>su", function()
  -- 获取lsp全称
  vim.ui.input({
    prompt = "📝 LSP全称: ",
    default = "",
  }, function(lspname)
    if not lspname or lspname == "" then
      return
    end

    -- 获取文件内容
    vim.ui.input({
      prompt = "📋 版本号: ",
      default = "",
    }, function(version)
      if not version or version == "" then
        return
      end
      OwnUtil.utils.update_lsp_version_when_not_newest(lspname, version)
    end)
  end)
end, { desc = "强制修改LSP版本号" })

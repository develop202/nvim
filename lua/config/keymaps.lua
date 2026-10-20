-- Add any additional keymaps here

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- nvim-treesitter 安装 parses
vim.keymap.set("n", "<leader>tsi", function()
  require("nvim-treesitter").install(OwnUtil.lang.treesitter, { summary = true })
end, { desc = "Install all parsers", expr = true, silent = true })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
vim.keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
vim.keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
vim.keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- lazy.nvim
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "lazy.nvim" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set("n", "<leader>gg", function()
    Snacks.lazygit({ cwd = vim.fn.getcwd() })
  end, { desc = "Lazygit (Root Dir)" })
end

-- local opts = { noremap = true, silent = true }

--窗口大小
vim.keymap.set("n", "<C-left>", "<C-w><", { desc = "向左调整窗口" })
vim.keymap.set("n", "<C-right>", "<C-w>>", { desc = "向右调整窗口" })
vim.keymap.set("n", "<C-up>", "<C-w>+", { desc = "向上调整窗口" })
vim.keymap.set("n", "<C-down>", "<C-w>-", { desc = "向下调整窗口" })
--左右滚动代码
vim.keymap.set({ "n", "v" }, "<A-left>", vim.opt.wrap and "10h" or "zH", { desc = "向左滚动代码" })
vim.keymap.set({ "n", "v" }, "<A-right>", vim.opt.wrap and "10l" or "zL", { desc = "向右滚动代码" })
-- 上下滚动代码
vim.keymap.set({ "n", "v" }, "<A-up>", "10k", { desc = "向上滚动代码" })
vim.keymap.set({ "n", "v" }, "<A-down>", "10j", { desc = "向下滚动代码" })
--关闭所有buffer
vim.keymap.set("n", "ca", "<cmd>bufdo bd<CR>", { desc = "关闭所有buffer" })

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
end, { desc = "修改LSP版本号" })

-- 辅助函数：查找 Mason 安装的工具路径
local function find_tool(tool)
  -- 优先从系统 PATH 查找
  local path = vim.fn.exepath(tool)
  if path ~= "" then
    return path
  end
  -- 回退到 Mason 默认 bin 目录
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. tool
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end
  return tool -- 返回原始命令名，让系统自行解析
end

-- 格式化函数：两步 npm-groovy-lint，先缩进1后缩进2，带超时
local function format_groovy_two_step()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("当前缓冲区没有文件名", vim.log.levels.WARN)
    return
  end

  -- 获取 npm-groovy-lint 可执行文件路径
  local groovy_lint = find_tool("npm-groovy-lint")

  -- 超时时间（秒），可根据需要调整
  local timeout_seconds = 10

  -- 构造两步命令，使用 timeout 限制每次执行时间
  -- 第一步：缩进1格
  local cmd_step1 = string.format(
    "timeout %ds node %s --fix --config '" .. vim.fn.stdpath("config") .. "/after/ftplugin/asset/groovy/lint.json" .. "' %s",
    timeout_seconds,
    groovy_lint,
    vim.fn.shellescape(filepath)
  )
  -- 第二步：缩进2格（依赖第一步完成）
  local cmd_step2 = string.format(
    "timeout %ds node %s --fix --config '" .. vim.fn.stdpath("config") .. "/after/ftplugin/asset/groovy/lint2.json" .. "' %s",
    timeout_seconds,
    groovy_lint,
    vim.fn.shellescape(filepath)
  )

  -- 用 && 确保顺序执行（先1后2）
  local full_cmd = cmd_step1 .. " && sleep 1"

  -- 同步执行，阻塞 Neovim 直到完成或超时
  local output = vim.fn.system(full_cmd)
  local exit_code = vim.v.shell_error

  -- 同步执行，阻塞 Neovim 直到完成或超时
  output = vim.fn.system(cmd_step2)
  exit_code = vim.v.shell_error

  if exit_code ~= 1 then
    vim.notify("Groovy 格式化失败（退出码 " .. exit_code .. "）:\n" .. output, vim.log.levels.ERROR)
  else
    vim.notify("Groovy 格式化完成", vim.log.levels.INFO)
    -- 重新加载文件以反映磁盘更改（因为 npm-groovy-lint 直接修改文件）
    vim.cmd("edit!")
  end
  -- end
end

-- 绑定快捷键（例如 <leader>gf）
vim.keymap.set("n", "<leader>gf", format_groovy_two_step, { desc = "Format Groovy (two-step)" })

-- windows
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

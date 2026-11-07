-- Add any additional keymaps here

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

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

-- 绑定快捷键（例如 <leader>gf）
vim.keymap.set("n", "<leader>gf", OwnUtil.lang.groovy.format_groovy_two_step, { desc = "Format Groovy (two-step)" })

-- windows
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

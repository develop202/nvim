-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local option = vim.opt
-- local buffer = vim.b
local global = vim.g

-- option.tabstop = 2
-- option.shiftwidth = 2
option.swapfile = false
option.hlsearch = false

-- 内置拼写检查
-- option.spell = true
option.spelllang = "en_us,cjk"
option.spelloptions = "camel"

-- 关闭透明显示
-- 关掉可以让cmp补全列表图标正常显示
option.pumblend = 0

global.autoformat = false
global.lazyvim_python_lsp = "basedpyright"
-- 关闭lazyvim里lualine的symbol显示
global.trouble_lualine = false

-- wsl粘贴板共享到宿主机
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --crlf",
      ["*"] = "win32yank.exe -o --crlf",
    },
    cache_enable = 0,
  }
end

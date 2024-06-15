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
-- option.autoindent = true
-- option.smartindent = true
-- Buffer Settings --
-- buffer.fileenconding = "utf-8"
-- 内置拼写检查
-- option.spell = true
option.spelllang = "en_us,cjk"
option.spelloptions = "camel"
-- Global Settings --
-- global.mapleader = " "
global.autoformat = false
-- global.lazyvim_python_ruff = "jedi_language_server"
-- global.lazyvim_python_ruff = "pylsp"

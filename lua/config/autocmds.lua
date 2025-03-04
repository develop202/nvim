-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- lsp inlayhint高亮
-- vim.cmd([[ hi LspInlayHint guibg=#3a3234 guifg=#928374]])

-- 取消换行自动注释
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

-- 自动显示光标所在行诊断信息
-- 干扰太多，暂时取消
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = vim.api.nvim_create_augroup("float_diagnostic_cursor", { clear = true }),
--   callback = function()
--     vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
--   end,
-- })

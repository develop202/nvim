-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- fix
-- diagnostics sign bg (next to numbers line)
vim.cmd([[ hi! DiagnosticSignOk guifg=#b8bb26 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignInfo guifg=#83a598 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignWarn guifg=#fabd2f guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignError guifg=#fb4934 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignHint guifg=#8ec07c guibg=NONE ]])

-- 关闭neo-tree git斜体
vim.cmd([[ hi! NeoTreeMessage guifg=#625d51 ]])
vim.cmd([[ hi! NeoTreeRootName gui=bold ]])
vim.cmd([[ hi! NeoTreeGitConflict gui=bold guifg=#ff8700 ]])
vim.cmd([[ hi! NeoTreeGitUntracked guifg=#ff8700 ]])

-- lsp document_highlight高亮组
vim.cmd([[ hi LspReferenceWrite guibg=#900C3F ]])
vim.cmd([[ hi LspReferenceRead guibg=#597266 ]])
vim.cmd([[ hi LspReferenceText guibg=#4c6280 ]])

-- 只有一个NONE无效
vim.cmd([[ hi TodoSignTEST guifg=#83a598 guibg=NONE ]])
vim.cmd([[ hi TodoSignHACK guifg=#fabd2f guibg=NONE ]])
vim.cmd([[ hi TodoSignNOTE guifg=#8ec07c guibg=NONE ]])
vim.cmd([[ hi TodoSignTODO guifg=#83a598 guibg=NONE ]])
vim.cmd([[ hi TodoSignWARN guifg=#fabd2f guibg=NONE ]])
vim.cmd([[ hi TodoSignFIX guifg=#fb4934 guibg=NONE ]])
vim.cmd([[ hi TodoSignPERF guifg=#83a598 guibg=NONE ]])

-- 取消换行自动注释
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

-- 自动显示光标所在行诊断信息
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("float_diagnostic_cursor", { clear = true }),
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
  end,
})

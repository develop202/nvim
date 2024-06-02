-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format { async = false, filter = function(client) if client.name == "tsserver" and vim.bo.filetype == "vue" then return client.name ~= "tsserver" end return client.name == client.name end}]]
-- vim.cmd [[autocmd BufWritePre * <leader>f]]
vim.cmd([[ autocmd BufEnter * set formatoptions+=/mBrj formatoptions-=o ]])
vim.api.nvim_exec(
  [[
autocmd FileType sql setlocal omnifunc=vim.dadbod_completion#omni
autocmd FileType sql,mysql,plsql lua require("cmp").setup.buffer({sources={{name='vim-dadbod-completion'}}})
]],
  false
)
-- fix
-- git signs column bg
-- vim.cmd([[ hi! SignColumn guibg=NONE ]])

-- fix
-- winbar bg
-- vim.cmd([[ hi! WinBar guibg=NONE ]])
-- vim.cmd([[ hi! WinBarNC guibg=NONE ]])

-- fix
-- noice cmd line bg
-- vim.cmd([[ hi! NoiceCmdlinePopup guibg=#282828 ]])
-- vim.cmd([[ hi! NoiceCmdlinePopupBorder guibg=#282828 ]])

-- fix
-- telescope selection bg
vim.cmd([[ hi! TelescopeSelection guibg=#3c3836 guifg=#fe8019 gui=bold ]])

-- fix
-- diagnostics sign bg (next to numbers line)
-- vim.cmd([[ hi! DiagnosticSignOk guifg=#b8bb26 guibg=#282828 ]])
vim.cmd([[ hi! DiagnosticSignOk guifg=#b8bb26 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignInfo guifg=#83a598 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignWarn guifg=#fabd2f guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignError guifg=#fb4934 guibg=NONE ]])
vim.cmd([[ hi! DiagnosticSignHint guifg=#8ec07c guibg=NONE ]])

-- fix
-- lsp saga bg
-- vim.cmd([[ hi! SagaNormal guibg=#282828 ]])
-- 关闭neo-tree git斜体
vim.cmd([[ hi! NeoTreeMessage guifg=#625d51 ]])
vim.cmd([[ hi! NeoTreeRootName gui=bold ]])
vim.cmd([[ hi! NeoTreeGitConflict gui=bold guifg=#ff8700 ]])
vim.cmd([[ hi! NeoTreeGitUntracked guifg=#ff8700 ]])
-- lsp document_highlight高亮组
vim.cmd([[ hi link LspReferenceWrite Visual ]])
vim.cmd([[ hi link LspReferenceRead Visual ]])
vim.cmd([[ hi link LspReferenceText Visual ]])
-- 文件拼写检查

-- 为具有特定扩展名的文件启用拼写检查
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.*" },
  callback = function()
    vim.opt.spell = true
  end,
})

-- 当你离开这些文件时，可以禁用拼写检查（可选）
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = { "*.*" },
  callback = function()
    vim.opt.spell = false
  end,
})

-- 或者，基于文件类型来设置（通常更健壮）
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "markdown", "text" },
--   callback = function()
--     vim.opt.spell = true
--   end,
-- })

-- 当你离开这些文件类型时，可以禁用拼写检查（可选）
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "*",
--   command = 'if &filetype !=# "markdown" && &filetype !=# "text" | setlocal nospell | endif',
--   nested = false, -- 可能需要设置为 false 以防止嵌套自动命令的干扰
-- })

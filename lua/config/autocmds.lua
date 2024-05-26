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
vim.cmd([[ hi! SignColumn guibg=NONE ]])

-- fix
-- winbar bg
vim.cmd([[ hi! WinBar guibg=NONE ]])
vim.cmd([[ hi! WinBarNC guibg=NONE ]])

-- fix
-- noice cmd line bg
vim.cmd([[ hi! NoiceCmdlinePopup guibg=#282828 ]])
vim.cmd([[ hi! NoiceCmdlinePopupBorder guibg=#282828 ]])

-- fix
-- telescope selection bg
vim.cmd([[ hi! TelescopeSelection guibg=#3c3836 guifg=#fe8019 gui=bold ]])

-- fix
-- diagnostics sign bg (next to numbers line)
vim.cmd([[ hi! DiagnosticSignOk guifg=#b8bb26 guibg=#282828 ]])
vim.cmd([[ hi! DiagnosticSignInfo guifg=#83a598 guibg=#282828 ]])
vim.cmd([[ hi! DiagnosticSignWarn guifg=#fabd2f guibg=#282828 ]])
vim.cmd([[ hi! DiagnosticSignError guifg=#fb4934 guibg=#282828 ]])
vim.cmd([[ hi! DiagnosticSignHint guifg=#8ec07c guibg=#282828 ]])

-- fix
-- lsp saga bg
-- vim.cmd([[ hi! SagaNormal guibg=#282828 ]])
-- 关闭neo-tree git斜体
vim.cmd([[ hi! NeoTreeMessage guifg=#625d51 ]])
vim.cmd([[ hi! NeoTreeRootName gui=bold ]])
vim.cmd([[ hi! NeoTreeGitConflict gui=bold guifg=#ff8700 ]])
vim.cmd([[ hi! NeoTreeGitUntracked guifg=#ff8700 ]])

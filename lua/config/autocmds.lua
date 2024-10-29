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

-- 取消fzf选择框背景色
vim.cmd([[ hi FzfLuaCursorLine guibg=#282828 ]])

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

--修正LazyVim文档高亮闪烁的问题
---@diagnostic disable-next-line: duplicate-set-field
LazyVim.lsp.words.setup = function(opts)
  ---@diagnostic disable-next-line: lowercase-global
  opts = opts or {}
  if not opts.enabled then
    return
  end
  LazyVim.lsp.words.enabled = true
  local handler = vim.lsp.handlers["textDocument/documentHighlight"]
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.lsp.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      return
    end
    if result == nil or not #result == 0 then
      vim.lsp.buf.clear_references()
    end
    return handler(err, result, ctx, config)
  end

  LazyVim.lsp.on_supports_method("textDocument/documentHighlight", function(_, buf)
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
      group = vim.api.nvim_create_augroup("lsp_word_" .. buf, { clear = true }),
      buffer = buf,
      callback = function(ev)
        if not require("lazyvim.plugins.lsp.keymaps").has(buf, "documentHighlight") then
          return false
        end

        if not ({ LazyVim.lsp.words.get() })[2] then
          if ev.event:find("CursorMoved") then
            vim.lsp.buf.clear_references()
          elseif not LazyVim.cmp.visible() then
            vim.lsp.buf.document_highlight()
          end
        end
      end,
    })
  end)
end

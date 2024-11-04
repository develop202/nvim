-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- lsp document_highlight高亮组
vim.cmd([[ hi LspReferenceWrite guibg=#900C3F ]])
vim.cmd([[ hi LspReferenceRead guibg=#597266 ]])
vim.cmd([[ hi LspReferenceText guibg=#4c6280 ]])

if vim.env.TERM ~= "xterm-kitty" and os.getenv("HOME") == "/data/data/com.termux/files/home" then
  -- 取消LazyNormal背景色
  vim.cmd([[ hi LazyNormal guibg=#282828 ]])

  -- 取消fzf选择框背景色
  vim.cmd([[ hi FzfLuaCursorLine guibg=#282828 ]])
end

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

    if result ~= nil and #result == 0 then
      return nil
    end

    vim.lsp.buf.clear_references()
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

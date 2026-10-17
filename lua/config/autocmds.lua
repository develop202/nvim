-- Add any additional autocmds here

-- bufferline高亮
vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", {
  fg = OwnUtil.utils.hl.get_hl("Normal").bg,
  bg = OwnUtil.utils.hl.get_hl("Normal").bg,
})

-- 取消换行自动注释
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*" },
  callback = function()
    -- r: 插入模式换行
    -- c: 自动换行
    -- o: 命令模式输入o/O换行
    vim.opt.formatoptions = vim.opt.formatoptions - { "o" }
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

-- 5. 设置自动命令：当该文件被加载后，立即执行我们的补丁逻辑
vim.api.nvim_create_autocmd("SourcePost", {
  pattern = { "**/vim-dadbod-ui/autoload/db_ui/drawer.vim" },
  callback = function()
    if not vim.g.db_ui_patching then
      OwnUtil.utils.patch_vim_plugin()
    end
  end,
})

-- 取消缩进线动画
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local filetype = args.match
    local exact_matches = {
      ["Outline"] = true,
      ["JavaProjects"] = true,
      ["dbui"] = true,

      ["Trouble"] = true,
      ["alpha"] = true,
      ["dashboard"] = true,
      ["fzf"] = true,
      ["help"] = true,
      ["lazy"] = true,
      ["mason"] = true,
      ["notify"] = true,
      ["toggleterm"] = true,
      ["trouble"] = true,
      ["snacks_dashboard"] = true,
    }
    if exact_matches[filetype] or string.find(filetype, "[%._-]") then
      vim.b[args.buf].miniindentscope_disable = true
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("neovim_treesitter", { clear = true }),
  callback = function(ev)
    -- highlighting
    pcall(vim.treesitter.start, ev.buf)

    OwnUtil.utils.treesitter_context_object_attach(ev.buf)
  end,
})

vim.o.clipboard = "unnamedplus"
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    (vim.hl or vim.highlight).on_yank()
    local copy_to_unnamedplus = require("vim.ui.clipboard.osc52").copy("+")
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require("vim.ui.clipboard.osc52").copy("*")
    copy_to_unnamed(vim.v.event.regcontents)
  end,
})

-- 自动读文件
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  callback = function(e)
    if e.file ~= "" then
      require("autoread").enable()
    end
  end,
})

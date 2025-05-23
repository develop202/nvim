-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- lsp inlayhint高亮
-- vim.cmd([[ hi LspInlayHint guibg=#3a3234 guifg=#928374]])

-- 修改高亮
vim.api.nvim_set_hl(0, "BlinkCmpLabelDeprecated", { fg = "#7E8294", bg = "NONE", strikethrough = true })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#46484a", fg = "NONE" })
vim.api.nvim_set_hl(0, "Pmenu", { fg = "#ebdbb2", bg = "#32302f" })
-- 取消换行自动注释
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

-- SpringBootIcon高亮
vim.api.nvim_set_hl(0, "SpringBootIcon", { fg = "#57965c" })
-- PropertiesIcon高亮
vim.api.nvim_set_hl(0, "PropertiesIcon", { fg = "#ced0d6" })

-- 自动显示光标所在行诊断信息
-- 干扰太多，暂时取消
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = vim.api.nvim_create_augroup("float_diagnostic_cursor", { clear = true }),
--   callback = function()
--     vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
--   end,
-- })

-- 退出前恢复文件
vim.api.nvim_create_autocmd("QuitPre", {
  group = vim.api.nvim_create_augroup("restore_files", { clear = true }),
  callback = function()
    -- 恢复java-dep图标与文字间隔
    if vim.g.java_deps_loaded then
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/java-deps.nvim/lua/java-deps/parser.lua",
        77,
        '    table.insert(lines, string_prefix .. icon .. " " .. node.label)'
      )
    end

    -- 恢复outline图标与文本间空格和高亮
    if vim.g.outline_is_loaded then
      -- 空格
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
        867,
        "    line = line .. ' ' .. node.name"
      )
      -- 高亮
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/outline.nvim/lua/outline/sidebar.lua",
        881,
        "    node.prefix_length = hl_end + 1"
      )
    end

    -- 恢复dbui图标与文字间隔
    if vim.g.dbui_loaded then
      -- 恢复
      OwnUtil.utils.termux_change_file_line(
        vim.fn.stdpath("data") .. "/lazy/vim-dadbod-ui/autoload/db_ui/drawer.vim",
        362,
        '  let content = map(copy(self.content), \'repeat(" ", shiftwidth() * v:val.level).v:val.icon.(!empty(v:val.icon) ? " " : "").v:val.label\')'
      )
    end
  end,
})

return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    {
      "kristijanhusak/vim-dadbod-completion",
      ft = { "sql", "mysql", "plsql" },
      lazy = true,
    },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    local pf = ""
    if OwnUtil.sys.is_termux() then
      pf = " "
    end
    -- Your DBUI configuration
    vim.g.db_ui_icons = {
      expanded = {
        db = "▾ 󰆼" .. pf,
        buffers = "▾ " .. pf,
        saved_queries = "▾ " .. pf,
        schemas = "▾ " .. pf,
        schema = "▾ 󰙅" .. pf,
        tables = "▾ 󰓱" .. pf,
        table = "▾ " .. pf,
      },
      collapsed = {
        db = "▸ 󰆼" .. pf,
        buffers = "▸ " .. pf,
        saved_queries = "▸ " .. pf,
        schemas = "▸ " .. pf,
        schema = "▸ 󰙅" .. pf,
        tables = "▸ 󰓱" .. pf,
        table = "▸ " .. pf,
      },
      saved_query = "  " .. pf,
      new_query = "  󰓰" .. pf,
      tables = "  󰓫" .. pf,
      buffers = "  " .. pf,
      add_connection = "  󰆺" .. pf,
      connection_ok = "✓",
      connection_error = "✕",
    }
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_use_nerd_fonts = 1
    -- 使用notify进行通知
    vim.g.db_ui_use_nvim_notify = true
    vim.g.db_ui_auto_execute_table_helpers = 1
    -- 对临时查询文件添加文件扩展.sql
    vim.g.Db_ui_buffer_name_generator = function(opts)
      if opts.table == nil or opts.table == "" then
        return os.date("%H:%M:%S") .. ".sql"
      else
        return opts.table .. os.date("%H:%M:%S") .. ".sql"
      end
    end
  end,
  keys = {
    {
      "<leader>D",
      function()
        -- 仅termux执行
        if OwnUtil.sys.is_termux() then
          if not vim.g.dbui_loaded then
            -- 去除空格
            OwnUtil.utils.termux_change_file_line(
              vim.fn.stdpath("data") .. "/lazy/vim-dadbod-ui/autoload/db_ui/drawer.vim",
              362,
              "  let content = map(copy(self.content), 'repeat(\" \", shiftwidth() * v:val.level).v:val.icon.v:val.label')"
            )
            -- 描述dbui已被使用
            vim.g.dbui_loaded = 1
          end
        end
        vim.cmd("DBUIToggle")
      end,
      desc = "Toggle DBUI",
    },
  },
}

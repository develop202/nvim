return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_icons = {
      expanded = {
        db = "▾" .. " 󰆼 ",
        buffers = "▾" .. "  ",
        saved_queries = "▾" .. "  ",
        schemas = "▾" .. "  ",
        schema = "▾" .. " 󰙅 ",
        tables = "▾" .. " 󰓱 ",
        table = "▾" .. "  ",
      },
      collapsed = {
        db = "▸" .. " 󰆼 ",
        buffers = "▸" .. "  ",
        saved_queries = "▸" .. "  ",
        schemas = "▸" .. "  ",
        schema = "▸" .. " 󰙅 ",
        tables = "▸" .. " 󰓱 ",
        table = "▸" .. "  ",
      },
      saved_query = "   ",
      new_query = "  󰓰 ",
      tables = "  󰓫 ",
      buffers = "   ",
      add_connection = "  󰆺 ",
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
}

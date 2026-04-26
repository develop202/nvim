return {

  {
    -- 自动保存
    "okuuva/auto-save.nvim",
    version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      -- your config goes here
      -- or just leave it empty :)
      debounce_delay = 200,
      write_all_buffers = true,
    },
  },

  {
    -- 自动读取
    "manuuurino/autoread.nvim",
    cmd = "Autoread",
    opts = {
      notify_on_change = false,
    },
  },
}

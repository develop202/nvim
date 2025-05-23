return {
  {
    "JuanZoran/Trans.nvim",
    build = function()
      require("Trans").install()
    end,
    keys = {
      -- 可以换成其他你想映射的键
      { "<leader>tm", mode = { "n", "x" }, "<Cmd>Translate<CR>", desc = "󰊿 Translate" },
      { "<leader>tk", mode = { "n", "x" }, "<Cmd>TransPlay<CR>", desc = " Auto Play" },
      -- 目前这个功能的视窗还没有做好，可以在配置里将view.i改成hover
      { "<leader>ti", "<Cmd>TranslateInput<CR>", desc = "󰊿 Translate From Input" },
    },
    dependencies = { "kkharji/sqlite.lua" },
    -- 主要用于单词翻译,没有申请api
    opts = {
      view = {
        i = "hover",
      },
      theme = "dracula",
      -- your configuration there
    },
  },
}

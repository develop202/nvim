return {
  {
    "folke/persistence.nvim",
    event = "BufReadPost",
    dependencies = "ibhagwan/fzf-lua",
    opts = {},
    keys = {
      -- 删除选择会话
      {
        "<leader>qD",
        function()
          require("persistence").delete()
        end,
        desc = "Delete Select Session",
      },

      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>qS",
        function()
          require("persistence").select()
        end,
        desc = "Select Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}

return {
  "kawre/leetcode.nvim",
  event = "VeryLazy",
  cmd = {
    "Leet"
  },
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- telescope 所需
    "MunifTanjim/nui.nvim",

    -- 可选
    "nvim-treesitter/nvim-treesitter",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    -- 配置放在这里
    cn = {
      enabled = true,
    },
    ---@type lc.lang
    lang = "java",
    ---@type lc.storage
    storage = {
      home = "~/.leetcode",
      cache = "~/.leetcode/cache",
    },
  },
}

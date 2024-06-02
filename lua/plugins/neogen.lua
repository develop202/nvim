return {
  "danymat/neogen",
  -- event = {
  --   "BufReadPost",
  --   "BufNewFile",
  -- },
  event = "LazyFile",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = true,
  -- Uncomment next line if you want to follow only stable versions
  -- version = "*"
}

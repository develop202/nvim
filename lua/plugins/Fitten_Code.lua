return {
  "luozhiya/fittencode.nvim",
  -- event = {
  --   "BufReadPost",
  --   "BufNewFile",
  -- },
  event = "LazyFile",
  config = function()
    local API = require("fittencode.api").api
    local Base = require("fittencode.base")
    Base.map("i", "<a-down>", API.accept_all_suggestions)
    require("fittencode").setup()
  end,
}

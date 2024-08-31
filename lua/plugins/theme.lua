return {
  -- add gruvbox

  {
    "ellisonleao/gruvbox.nvim",
    opts = {
      italic = {
        strings = false,
        emphasis = false,
        comments = false,
        operators = false,
        folds = false,
      },
      -- 修改Java文件关键词(public static)高亮为红色，不改为黄色
      overrides = {
        ["@type.qualifier"] = { link = "@keyword" },
      },
    },
    -- config = function()
    --   require("gruvbox").setup({
    --     italic = {
    --       strings = false,
    --       emphasis = false,
    --       comments = false,
    --       operators = false,
    --       folds = false,
    --     },
    --   })
    -- end
  },
  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

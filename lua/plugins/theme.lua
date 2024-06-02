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

return {
  {
    "uga-rosa/ccc.nvim",
    -- 只用来修改颜色
    event = { "LazyFile" },
    config = function()
      -- Enable true color
      vim.opt.termguicolors = true

      local ccc = require("ccc")
      -- local mapping = ccc.mapping

      ccc.setup({
        -- Your preferred settings
        -- Example: enable highlighter
        highlighter = {
          auto_enable = false,
          lsp = false,
        },
      })
    end,
  },
  {
    "brenoprata10/nvim-highlight-colors",
    -- 只用来颜色高亮
    event = { "LazyFile" },
    config = function()
      -- Ensure termguicolors is enabled if not already
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup({})
    end,
  },
  {
    "hiphish/rainbow-delimiters.nvim",
    event = { "LazyFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        style_preset = require("bufferline").style_preset.no_italic,
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        -- 将文件名提到开头，路径颜色变暗
        path_display = {
          filename_first = {
            reverse_directories = false,
          },
        },
        -- 显示右侧预览，不过在手机上很窄，不美观
        -- layout_strategy = "horizontal",
        -- layout_config = {
        --   width = 0.8,
        --   preview_cutoff = 1,
        -- },
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            preview_cutoff = 20,
            preview_height = 0.6,
            -- mirror = true,
          },
          -- height = { padding = 0 },
          -- width = { padding = 0 },
        },
      },
      -- 预览和搜索结果上下分布，看着有些怪，但是搜索结果显示完整一些
      -- pickers = {
      --   find_files = {
      --     theme = "dropdown",
      --   },
      -- },
    },
  },
}

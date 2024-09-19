return {
  -- {
  --   "RRethy/vim-illuminate",
  --   -- event = "LazyFile",
  --   opts = function(_, opts)
  --     local regi = {
  --       vim.api.nvim_set_hl(0, "IlluminatedWordText", {
  --         link = "Visual",
  --       }),
  --       vim.api.nvim_set_hl(0, "IlluminatedWordRead", {
  --         link = "Visual",
  --       }),
  --       vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {
  --         link = "Visual",
  --       }),
  --     }
  --     table.insert(opts, regi)
  --   end,
  --   -- config = function()
  --   --   require("illuminate").configure()
  --   -- end,
  -- },
  -- {
  --   "NvChad/nvim-colorizer.lua",
  --   -- event = { "BufReadPost", "BufNewFile" },
  --   event = { "LazyFile" },
  --   cmd = { "ColorizerToggle", "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers" },
  --   -- opts = { user_default_options = { names = false } },
  --   config = function()
  --     -- require 'colorizer'.setup()
  --     -- Attach to buffer
  --     require("colorizer").attach_to_buffer(0, { mode = "background", css = true })
  --   end
  -- },
  -- {
  --   "norcalli/nvim-colorizer.lua",
  --   event = "LazyFile",
  --   config = function()
  --     require("colorizer").setup()
  --   end,
  -- },
  {
    "uga-rosa/ccc.nvim",
    -- ft = { "html", "css", "scss", "less", "vue" },
    -- event = { "BufReadPost", "BufNewFile" },
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
    -- event = { "BufReadPost", "BufNewFile" },
    event = { "LazyFile" },
    --   -- 这个插件很奇怪，
    --   -- 不管用init,opts还是config禁止高亮，
    --   -- 都不生效，进文件一段时间后还是
    --   -- 会显示颜色，不过好在禁止高亮后用ccc.nvim的颜色选择器可以修改颜色了
    --   init = function()
    --     -- Ensure termguicolors is enabled if not already
    --     vim.opt.termguicolors = true
    --
    --     require("nvim-highlight-colors").setup({
    --       ---Highlight hex colors, e.g. '#FFFFFF'
    --       enable_hex = false,
    --
    --       ---Highlight short hex colors e.g. '#fff'
    --       enable_short_hex = false,
    --
    --       ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
    --       enable_rgb = false,
    --
    --       ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
    --       enable_hsl = false,
    --
    --       ---Highlight CSS variables, e.g. 'var(--testing-color)'
    --       enable_var_usage = true,
    --
    --       ---Highlight named colors, e.g. 'green'
    --       enable_named_colors = true,
    --     })
    --   end,
    --   opts = {
    --     ---Highlight hex colors, e.g. '#FFFFFF'
    --     enable_hex = false,
    --
    --     ---Highlight short hex colors e.g. '#fff'
    --     enable_short_hex = false,
    --
    --     ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
    --     enable_rgb = false,
    --
    --     ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
    --     enable_hsl = false,
    --
    --     ---Highlight CSS variables, e.g. 'var(--testing-color)'
    --     --- 只需要开启这一个，其他自己会自动开启
    --     enable_var_usage = true,
    --
    --     ---Highlight named colors, e.g. 'green'
    --     enable_named_colors = true,
    --   },
    config = function()
      -- Ensure termguicolors is enabled if not already
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup({
        --
        --     ---Highlight hex colors, e.g. '#FFFFFF'
        --     enable_hex = false,
        --
        --     ---Highlight short hex colors e.g. '#fff'
        --     enable_short_hex = false,
        --
        --     ---Highlight rgb colors, e.g. 'rgb(0 0 0)'
        --     enable_rgb = false,
        --
        --     ---Highlight hsl colors, e.g. 'hsl(150deg 30% 40%)'
        --     enable_hsl = false,
        --
        --     ---Highlight CSS variables, e.g. 'var(--testing-color)'
        --     enable_var_usage = true,
        --
        --     ---Highlight named colors, e.g. 'green'
        --     enable_named_colors = true,
      })
    end,
  },
  {
    "hiphish/rainbow-delimiters.nvim",
    event = { "LazyFile" }, --,"BufReadPost", "BufNewFile" },
    config = function()
      require("rainbow-delimiters.setup").setup({})
    end,
    -- config = function()
    --   -- require("rainbow-delimiters.setup").setup({})
    --   -- This module contains a number of default definitions
    --   local rainbow_delimiters = require 'rainbow-delimiters'
    --
    --   ---@type rainbow_delimiters.config
    --   vim.g.rainbow_delimiters = {
    --     strategy = {
    --       [''] = rainbow_delimiters.strategy['global'],
    --       vim = rainbow_delimiters.strategy['local'],
    --     },
    --     query = {
    --       [''] = 'rainbow-delimiters',
    --       lua = 'rainbow-blocks',
    --     },
    --     priority = {
    --       [''] = 110,
    --       lua = 210,
    --     },
    --     highlight = {
    --       'RainbowDelimiterRed',
    --       'RainbowDelimiterYellow',
    --       'RainbowDelimiterBlue',
    --       'RainbowDelimiterOrange',
    --       'RainbowDelimiterGreen',
    --       'RainbowDelimiterViolet',
    --       'RainbowDelimiterCyan',
    --     },
    --   }
    -- end
  },
  -- {
  --   "tamton-aquib/duck.nvim",
  --   config = function()
  --     vim.keymap.set("n", "<leader>du", function()
  --       require("duck").hatch()
  --     end, {})
  --     vim.keymap.set("n", "<leader>dk", function()
  --       require("duck").cook()
  --     end, {})
  --     vim.keymap.set("n", "<leader>dl", function()
  --       require("duck").cook_all()
  --     end, {})
  --   end,
  -- },
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

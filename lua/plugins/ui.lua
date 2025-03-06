return {
  {
    "uga-rosa/ccc.nvim",
    -- 只用来修改颜色
    event = { "LazyFile" },
    opts = {
      highlighter = {
        auto_enable = false,
        lsp = false,
      },
    },
  },
  -- {
  --   "brenoprata10/nvim-highlight-colors",
  --   -- 只用来显示补全栏颜色
  --   event = { "LazyFile" },
  --   opts = {
  --     render = "virtual",
  --     virtual_symbol = "󱓻 ",
  --     virtual_symbol_suffix = "",
  --     enable_tailwind = true,
  --   },
  -- },
  {
    "catgoose/nvim-colorizer.lua",
    event = {
      -- "BufReadPre",
      "BufNew",
      "BufRead",
      "BufWritePost",
      "TextChanged",
      "TextChangedI",
      "StdinReadPre",
    },
    opts = {
      filetypes = {
        "*", -- Highlight all files, but customize some others.
        -- 不在cmp补全项里显示
        "!cmp_menu",
        -- cmp_menu = {
        --   always_update = true,
        -- },
        -- 不在cmp介绍里面显示
        "!cmp_docs",
        -- cmp_docs = {
        --   always_update = true,
        -- },
      },
      user_default_options = {
        rgb_fn = true,
        hsl_fn = true,
        mode = "virtualtext",
        virtualtext = "󰝤",
        virtualtext_inline = "before",
        tailwind = true,
      },
    },
  },
  {
    "hiphish/rainbow-delimiters.nvim",
    event = { "LazyFile" },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_z = nil
      opts.sections.lualine_y = nil
    end,
  },
}

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
  {
    "brenoprata10/nvim-highlight-colors",
    -- 只用来颜色高亮
    event = { "LazyFile" },
    opts = {
      render = "virtual",
      virtual_symbol = "󱓻 ",
      virtual_symbol_suffix = "",
      enable_tailwind = true,
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

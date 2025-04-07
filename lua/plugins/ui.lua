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
    "catgoose/nvim-colorizer.lua",
    event = {
      "BufReadPre",
    },
    opts = {
      filetypes = {
        -- "*",
        "htmldjango",
        "tsx",
        "jsx",
        "erb",
        "svelte",
        "vue",
        "blade",
        "php",
        "templ",
        "astro",
        "html",
        "scss",
        "css",
        "less",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "markdown",
        "lua",
        "go",
        "kotlin",
        "dart",
        -- 不在cmp补全项里显示
        -- "!cmp_label",
        -- cmp_menu = {
        --   always_update = true,
        -- },
        -- 不在cmp介绍里面显示
        -- "!cmp_document",
        -- "!lazy",
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
      if OwnUtil.sys.is_termux() then
        opts.sections.lualine_c[4] = {
          function()
            return "󰌾"
          end,
          cond = function()
            return vim.bo.readonly
          end,
          color = function()
            return { gui = "bold" }
          end,
        }
      end
      opts.sections.lualine_z = nil
      opts.sections.lualine_y = nil
    end,
  },
}

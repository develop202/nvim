return {

  {
    -- 颜色选择器
    "uga-rosa/ccc.nvim",
    -- 只用来修改颜色
    event = { "BufReadPre" },
    opts = {
      highlighter = {
        auto_enable = false,
        lsp = false,
      },
    },
  },

  {
    -- 下方状态栏
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

  {
    -- 上方文件tab栏
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      local bg = { attribute = "bg", highlight = "Normal" }
      -- 悬停
      opts.options.hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      }

      -- 修改背景色统一
      opts.highlights = {
        fill = { bg = bg },
        background = { bg = bg },
        close_button = { bg = bg },
        tab_separator = { bg = bg },
        tab_separator_selected = { bg = bg },

        warning_diagnostic = { bg = bg },
        tab = { bg = bg },
        tab_close = { bg = bg },
        buffer = { bg = bg },
        numbers = { bg = bg },
        diagnostic = { bg = bg },
        hint = { bg = bg },
        hint_diagnostic = { bg = bg },
        info = { bg = bg },
        info_diagnostic = { bg = bg },
        warning = { bg = bg },
        error = { bg = bg },
        error_diagnostic = { bg = bg },
        modified = { bg = bg },
        duplicate = { bg = bg },
        separator = { fg = bg, bg = bg },
        pick = { bg = bg },
        offset_separator = { bg = bg },
        trunc_marker = { bg = bg },
      }
    end,
  },
}

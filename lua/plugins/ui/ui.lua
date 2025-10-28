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
      filetypes = OwnUtil.utils.ft.show_color_ft,
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
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      -- 修改背景色统一
      opts.highlights = {
        fill = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        background = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        close_button = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        tab_separator = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        tab_separator_selected = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },

        warning_diagnostic = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        tab = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        tab_close = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        buffer = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        numbers = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        diagnostic = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        hint = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        hint_diagnostic = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        info = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        info_diagnostic = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        warning = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        error = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        error_diagnostic = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        modified = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        duplicate = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        separator = {
          fg = {
            attribute = "bg",
            highlight = "Normal",
          },
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        pick = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        offset_separator = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
        trunc_marker = {
          bg = {
            attribute = "bg",
            highlight = "Normal",
          },
        },
      }
    end,
  },
}

return {
  {
    "Jezda1337/nvim-html-css",
    ft = OwnUtil.utils.ft.cmp_html_css_ft,
    opts = {
      enable_on = OwnUtil.utils.ft.cmp_html_css_ft,
      documentation = {
        auto_show = true,
      },
      style_sheets = {},
    },
  },

  {
    -- nvim-cmp补全源兼容层
    "saghen/blink.compat",
    version = "*",
    lazy = true, -- Automatically loads when required by blink.cmp
    opts = {},
  },
  {
    "Saghen/blink.cmp",
    optional = true,
    dependencies = {
      -- "Jezda1337/nvim-html-css",
      {
        "brenoprata10/nvim-highlight-colors",
        -- 只用来显示补全栏颜色
        config = function() end,
      },
    },
    opts = {
      completion = {
        list = {
          selection = {
            -- 禁用自动插入
            auto_insert = false,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },

            components = {
              -- customize the drawing of kind icons
              kind_icon = {
                text = function(ctx)
                  -- default kind icon
                  local icon = ctx.kind_icon
                  -- if LSP source, check for color derived from documentation
                  if ctx.item.source_name == "LSP" and ctx.kind_icon == " " then
                    local color_item =
                      require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr then
                      icon = "󰝤 "
                    end
                  end
                  return icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  -- default highlight group
                  local highlight = "BlinkCmpKind" .. ctx.kind
                  -- if LSP source, check for color derived from documentation
                  if ctx.item.source_name == "LSP" then
                    local color_item =
                      require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
                    if color_item and color_item.abbr_hl_group then
                      highlight = color_item.abbr_hl_group
                    end
                  end
                  return highlight
                end,
              },
              label = {
                width = {
                  fill = true,
                  max = 30,
                },
              },
              label_description = {
                width = {
                  max = 20,
                },
              },
            },
          },
        },
      },
      sources = {
        default = { "html-css" },
        providers = {
          -- 添加源
          ["html-css"] = {
            name = "html-css",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}

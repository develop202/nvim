local label_width = 40
local label_description_width = 30

local cmp_docs_max_width = 80
local cmp_docs_max_height = 20
if OwnUtil.sys.is_termux() then
  label_width = math.floor(0.6 * vim.o.columns)
  label_description_width = math.floor(0.35 * vim.o.columns)
  cmp_docs_max_width = math.floor(0.5 * vim.o.columns)
  cmp_docs_max_height = 10
end
return {
  {
    "Jezda1337/nvim-html-css",
    ft = OwnUtil.utils.ft.cmp_html_css_ft,
    opts = function()
      require("html-css.utils").read_file = function(path, cb)
        if string.match(path, "buffer:") then
          path = vim.split(path, ":")[2]
        end
        vim.uv.fs_open(path, "r", 438, function(err, fd)
          assert(not err, err)
          vim.uv.fs_fstat(fd, function(err, stat)
            assert(not err, err)
            vim.uv.fs_read(fd, stat.size, 0, function(err, data)
              assert(not err, err)
              vim.uv.fs_close(fd, function(err)
                assert(not err, err)
                return cb(data)
              end)
            end)
          end)
        end)
      end
      return {
        enable_on = OwnUtil.utils.ft.cmp_html_css_ft,
        documentation = {
          auto_show = true,
        },
        style_sheets = {},
      }
    end,
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
        ghost_text = {
          show_with_selection = false,
        },
        documentation = {
          window = {
            -- 特殊手段防止遮挡补全项
            min_width = 1,
            max_height = cmp_docs_max_height,
            max_width = cmp_docs_max_width,
          },
        },
        list = {
          selection = {
            -- 禁用自动插入
            auto_insert = false,
          },
        },
        menu = {
          draw = {
            -- 取消补全项图标与文本间的空格
            gap = 0,
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
                  max = label_width,
                },
              },
              label_description = {
                width = {
                  max = label_description_width,
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

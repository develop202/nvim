return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          -- termux屏幕窄，补全列表显示不全，所以写死了
          if os.getenv("HOME") == "/data/data/com.termux/files/home" and vim.o.filetype == "java" then
            -- 控制cmp补全框宽度
            local str = require("cmp.utils.str")
            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 15,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }
            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(str.trim(item[key])) > width then
                item[key] = vim.fn.strcharpart(str.trim(item[key]), 0, width - 1) .. "…"
              end
            end
          end
          local icons = require("lazyvim.config").icons.kinds
          -- 意义不大" "
          if icons[item.kind] then
            item.kind = icons[item.kind]
          end
          if item.kind == " " then
            local utils = require("nvim-highlight-colors.utils")
            local colors = require("nvim-highlight-colors.color.utils")

            local entryItem = entry:get_completion_item()
            if entryItem == nil then
              return item
            end

            local entryDoc = entryItem.documentation
            if entryDoc == nil or type(entryDoc) ~= "string" then
              return item
            end

            local color_hex = colors.get_color_value(entryDoc)
            if color_hex == nil then
              return item
            end
            local highlight_group = utils.create_highlight_name("fg-" .. color_hex)
            vim.api.nvim_set_hl(0, highlight_group, { fg = color_hex, default = true })

            item.kind_hl_group = highlight_group
            item.kind = "󱓻 "
            return item
          end
          local source = entry.source.name
          if source == "html-css" then
            item.menu = ("[" .. entry.completion_item.provider .. "]") or "[html-css]"
          end
          return item
        end,
      }
      table.insert(opts.sources, {
        name = "html-css",
        option = {
          enable_on = { "html", "vue", "css" }, -- html is enabled by default
          notify = false,
          documentation = {
            auto_show = true, -- show documentation on select
          },
          -- add any external scss like one below
          style_sheets = {},
        },
      })
    end,
  },
  {
    "Jezda1337/nvim-html-css",
  },
}

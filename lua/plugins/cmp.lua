return {
  {
    "hrsh7th/nvim-cmp",
    options = true,
    dependencies = {
      -- "Jezda1337/nvim-html-css",
      {
        "brenoprata10/nvim-highlight-colors",
        -- 只用来显示补全栏颜色
        config = function() end,
      },
    },
    opts = function(_, opts)
      opts.formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          -- termux屏幕窄，补全列表显示不全，所以写死了
          if OwnUtil.sys.is_termux() then
            -- 控制cmp补全框宽度
            local str = require("cmp.utils.str")
            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }
            for key, width in pairs(widths) do
              if item[key] and vim.fn.strdisplaywidth(str.trim(item[key])) > width then
                item[key] = vim.fn.strcharpart(str.trim(item[key]), 0, width - 1) .. "…"
              end
            end
          end
          local icons = require("lazyvim.config").icons.kinds
          local source = entry.source
          -- 意义不大" "
          if icons[item.kind] then
            item.kind = icons[item.kind]
          end

          local is_emmet = source:get_debug_name() == "nvim_lsp:emmet_language_server"
            or (source:get_debug_name() == "nvim_lsp:volar" and item.kind == icons["Text"])
          -- 自定义emmet样式
          if is_emmet then
            item.kind = icons["Property"]
            item.menu = "Emmet 缩写"
          end

          if item.menu == "" or item.menu == nil then
            if source.name == "nvim_lsp" then
              local debug_name = source:get_debug_name()
              item.menu = vim.split(debug_name, ":")[2]
            else
              item.menu = source.name
            end
          end

          if item.kind == icons["Color"] then
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
            item.kind = "󰝤 "
            return item
          end
          if source.name == "html-css" then
            item.menu = ("[" .. entry.completion_item.provider .. "]") or "[html-css]"
          end

          return item
        end,
      }
      -- nvim_lsp源过滤
      opts.sources[2].entry_filter = function(entry, ctx)
        local kinds = require("cmp.types").lsp.CompletionItemKind
        -- 过滤vtsls补全字符串
        if entry.source:get_debug_name() == "nvim_lsp:vtsls" then
          return kinds[entry:get_kind()] ~= "Text"
        end

        return true
      end
      table.insert(opts.sources, {
        name = "html-css",
        option = {
          enable_on = { "html", "vue" }, -- html is enabled by default
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
    ft = { "html", "vue" },
  },
}

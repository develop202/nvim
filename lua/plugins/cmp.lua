return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = require("lazyvim.config").icons.kinds
          local myicons = {
            Array = " ",
            Boolean = " ",
            Class = " ",
            Color = " ",
            Control = " ",
            Collapsed = " ",
            Constant = " ",
            Constructor = " ",
            Enum = " ",
            EnumMember = " ",
            Event = " ",
            Field = " ",
            File = " ",
            Folder = " ",
            Function = "󰊕 ",
            Interface = " ",
            Key = "󰌋 ",
            Keyword = " ",
            Method = " ",
            Module = " ",
            Namespace = " ",
            Null = " ",
            Number = "󰎠 ",
            Object = " ",
            Operator = " ",
            Package = " ",
            Property = " ",
            Reference = " ",
            Snippet = " ",
            String = " ",
            Struct = " ",
            TabNine = "󰏚 ",
            Text = "󰉿 ",
            TypeParameter = " ",
            Unit = " ",
            Value = " ",
            Variable = " ",
          }
          -- 意义不大" "
          -- 合并icons
          icons = vim.tbl_deep_extend("force", {}, icons, myicons or {})
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
          return item
        end,
      },
    },
  },
}

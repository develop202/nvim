return {
  {
    -- "onsails/lspkind.nvim",
    "hrsh7th/nvim-cmp",
    opts = {
      -- 修改cmp补全框的样式
      -- window = {
      --   completion = {
      --     winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      --     -- col_offset = -3,
      --     side_padding = 0,
      --   },
      -- },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(_, item)
          local icons = require("lazyvim.config").icons.kinds
          local myicons = {
            Array = " ",
            Boolean = " ",
            Class = " ",
            -- Codeium       = "󰘦 ",
            Color = " ",
            Control = " ",
            Collapsed = " ",
            Constant = " ",
            Constructor = " ",
            -- Copilot       = " ",
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
          -- if _.source.name == "nvim_lsp" and (vim.bo.filetype == "html" or vim.bo.filetype == "vue") then
          --   icons.Text = " "
          -- end
          -- 合并icons
          icons = vim.tbl_deep_extend("force", {}, icons, myicons or {})
          if vim.bo.filetype == "sql" or vim.bo.filetype == "mysql" then
            icons.Text = " "
          end
          if icons[item.kind] then
            item.kind = icons[item.kind]
          end
          return item
        end,
      },
    },
  },
  {
    "hrsh7th/cmp-cmdline",
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup.cmdline("/", {
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          {
            name = "buffer",
          },
        },
      })
      -- cmp.setup.cmdline(':', {
      --   completion = { completeopt = 'menu,menuone,noselect' },
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
      --     {
      --       name = 'path'
      --     },
      --     {
      --       name = 'cmdline'
      --     }
      --   })
      -- })
    end,
  },
  -- {
  --   "L3MON4D3/LuaSnip",
  --   event = "InsertEnter",
  -- },
  -- {
  --   "garymjr/nvim-snippets",
  --   event = "LazyFile",
  --   enabled = true,
  -- },
  -- {
  --   "p00f/clangd_extensions.nvim",
  --   ft = { "c", "cpp", "objcpp", "objc", "cuda", "proto" },
  --   event = "LazyFile",
  --   -- lazy = false
  -- },
}

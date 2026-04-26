-- 面包屑导航
local truncate = true
local sources = {
  path = {
    max_depth = 16,
  },
}

if OwnUtil.sys.is_termux() then
  -- 面包屑导航
  truncate = false
  -- 手机上隐藏路径
  sources.path.max_depth = 1
end

return {

  {
    -- 面包屑导航
    "Bekaboo/dropbar.nvim",
    event = "BufReadPre",
    opts = {
      sources = sources,
      bar = {
        truncate = truncate,
      },
      icons = {
        kinds = {
          symbols = OwnUtil.icons.kinds,
        },
      },
    },
  },

  {
    -- 代码折叠
    "kevinhwang91/nvim-ufo",
    event = "BufReadPre",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      -- global handler
      return {
        -- 自动折叠导入内容
        -- close_fold_kinds_for_ft = {
        --   default = { "imports" },
        -- },
        fold_virt_text_handler = handler,

        preview = {},
        open_fold_hl_timeout = 150,
        UfoConfig = {},
        enable_get_fold_virt_text = false,
        provider_selector = function(bufnr, filetype, buftype)
          if filetype == "vue" or filetype == "html" then
            -- 使用treesitter作为折叠依据
            return { "treesitter", "indent" }
          end
          return { "lsp", "indent" }
        end,
      }
    end,
  },

  {
    -- 颜色
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
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
    -- 彩虹括号
    "hiphish/rainbow-delimiters.nvim",
    event = { "BufReadPre" },
  },

  {
    -- 注释
    "numToStr/Comment.nvim",
    event = "BufReadPre",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      opts = {
        enable_autocmd = false,
      },
    },
    opts = function()
      -- 不知道为什么只能用function
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },

}

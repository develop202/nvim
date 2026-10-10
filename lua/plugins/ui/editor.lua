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
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false, show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "Trouble",
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
      },
    },
    main = "ibl",
  },

  {
    "nvim-mini/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "BufReadPost",
    opts = {
      -- symbol = "▏",
      symbol = "│",
      options = { try_as_border = true },
    },
  },

  {
    -- 面包屑导航
    "Bekaboo/dropbar.nvim",
    event = "BufReadPost",
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
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = {
      -- 自动折叠导入内容
      -- close_fold_kinds_for_ft = {
      --   default = { "imports" },
      -- },
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
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
      end,
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
    },
    keys = { "zc", "zo" },
  },

  {
    -- 颜色
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPost",
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
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "BufReadPost",
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
  },
  {
    -- 彩虹括号
    "hiphish/rainbow-delimiters.nvim",
    event = { "BufReadPost" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- lazy = false,
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
  },
}

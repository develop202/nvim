return {
  {
    -- 颜色选择器
    "uga-rosa/ccc.nvim",
    cmd = "CccPick",
    -- 只用来修改颜色
    opts = {
      highlighter = {
        auto_enable = false,
        lsp = false,
      },
    },
  },

  {
    -- 下方状态栏
    "echasnovski/mini.statusline",
    -- enabled = vim.g.mini_statusline or false,
    event = vim.g.mini_statusline and "VeryLazy" or {},
    config = function()
      local statusline = require("mini.statusline")
      local icons = OwnUtil.icons

      -- 1. 定义全透明高亮组 (强制背景为 NONE)
      local function set_trans_hl(name, fg)
        vim.api.nvim_set_hl(0, name, { fg = fg, bg = "NONE", force = true })
      end

      -- 初始化 Gruvbox 风格的动态颜色 (仅字体变色)
      local mode_colors = {
        n = "#83a598",
        i = "#b8bb26",
        v = "#fe8019",
        V = "#fe8019",
        [" "] = "#fe8019",
        c = "#fabd2f",
        R = "#fb4934",
      }

      -- 2. 辅助函数
      local function wrap_hl(hl, content)
        if not content or content == "" then
          return ""
        end
        return "%#" .. hl .. "#" .. content .. "%*"
      end

      local function truncate(str, max_len)
        if not str or str == "" then
          return ""
        end
        return #str > max_len and str:sub(1, max_len - 1) .. "…" or str
      end

      statusline.setup({
        set_vim_settings = true,
        content = {
          active = function()
            local win_width = vim.api.nvim_win_get_width(0)
            local cur_mode = vim.api.nvim_get_mode().mode
            local mode_color = mode_colors[cur_mode] or mode_colors.n
            local exclude = {
              -- "neo-tree",
              "snacks_dashboard",
              -- "symbols-outline",
            }
            for _, value in pairs(exclude) do
              if value == vim.bo.filetype then
                return ""
              end
            end

            -- 实时更新模式高亮 (只有字变色)
            set_trans_hl("StatusModeDynamic", mode_color)
            set_trans_hl("StatusNormal", "#ebdbb2") -- Gruvbox Foreground
            set_trans_hl("StatusKeyRed", "#fb4934") -- Gruvbox Red
            set_trans_hl("StatusGray", "#928374") -- Gruvbox Gray

            ----------------------------------------------------------------
            -- [左侧组件]
            ----------------------------------------------------------------
            -- A. 模式
            local mode_name = statusline.section_mode({ trunc_width = 80 }):upper()
            local mode_comp = wrap_hl("StatusModeDynamic", " " .. mode_name)

            -- B. Git 分支 (动态截取)
            local git_status = ""
            local git_dict = vim.b.gitsigns_status_dict
            if git_dict then
              local branch_limit = win_width > 100 and 15 or 8
              git_status = wrap_hl("StatusGray", "  " .. truncate(git_dict.head or "", branch_limit))
            end

            -- C. 代码诊断
            local function get_diag(sev, icon, hl)
              local count = #vim.diagnostic.get(0, { severity = sev })
              return count > 0 and wrap_hl(hl, " " .. icon .. count) or ""
            end
            local diags = get_diag(vim.diagnostic.severity.ERROR, icons.diagnostics.Error, "DiagnosticError")
              .. get_diag(vim.diagnostic.severity.WARN, icons.diagnostics.Warn, "DiagnosticWarn")
              .. get_diag(vim.diagnostic.severity.HINT, icons.diagnostics.Hint, "DiagnosticHint")
              .. get_diag(vim.diagnostic.severity.INFO, icons.diagnostics.Info, "DiagnosticInfo")

            -- D. 文件图标 (右侧，保留原色)
            local ft_icon = ""
            local ft = vim.bo.filetype
            local icon, icon_hl = require("nvim-web-devicons").get_icon_by_filetype(ft, { default = true })
            ft_icon = wrap_hl(icon_hl, " " .. icon .. " "--[[ .. " " .. ft ]])

            -- E. 调试图标 (右侧，保留原色)
            local debug_info = ""
            if package.loaded["dap"] and require("dap").status() ~= "" then
              debug_info = wrap_hl("StatusKeyRed", "  " .. require("dap").status())
            end

            ----------------------------------------------------------------
            -- [右侧组件]
            ----------------------------------------------------------------

            -- F. 当前按键 (左侧，红色，截取)
            local curr_keys = ""
            ---@diagnostic disable-next-line: undefined-field
            if package.loaded["noice"] and require("noice").api.status.command.has() then
              local keys_limit = win_width > 100 and 20 or 10
              curr_keys =
                ---@diagnostic disable-next-line: undefined-field
                wrap_hl("StatusKeyRed", " " .. truncate(require("noice").api.status.command.get(), keys_limit))
            end
            -- G. Git Diff
            local diff = ""
            if git_dict and win_width > 30 then
              local a, c, r = git_dict.added or 0, git_dict.changed or 0, git_dict.removed or 0
              diff = (a > 0 and wrap_hl("GitSignsAdd", " " .. icons.git.added .. a) or "")
                .. (c > 0 and wrap_hl("GitSignsChange", " " .. icons.git.modified .. c) or "")
                .. (r > 0 and wrap_hl("GitSignsDelete", " " .. icons.git.removed .. r) or "")
            end

            -- H. 位置与百分比
            local location = wrap_hl("StatusModeDynamic", " %P %l:%v ")

            ----------------------------------------------------------------
            -- [组装]
            -- 使用单个空格拼接，中间截断由 truncate 函数和组件优先级控制
            ----------------------------------------------------------------
            local left = table.concat(
              vim.tbl_filter(function(s)
                return s ~= ""
              end, {
                mode_comp,
                git_status,
                diags,
                ft_icon,
                debug_info,
              }),
              ""
            )

            local right = table.concat(
              vim.tbl_filter(function(s)
                return s ~= ""
              end, {
                curr_keys,
                diff,
                location,
              }),
              ""
            )
            return left .. " %=" .. right
          end,
        },
      })

      -- 强制全局背景透明
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
    end,
  },
  {
    -- 上方文件tab栏
    "akinsho/bufferline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = function()
      local bg = { attribute = "bg", highlight = "Normal" }
      return {
        options = {
          -- 悬停
          hover = {
            enabled = true,
            delay = 200,
            reveal = { "close" },
          },

        -- stylua: ignore
        close_command = function(n) Snacks.bufdelete(n) end,
        -- stylua: ignore
        right_mouse_command = function(n) Snacks.bufdelete(n) end,
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          diagnostics_indicator = function(_, _, diag)
            local ret = (diag.error and " " .. diag.error .. " " or "")
              .. (diag.warning and " " .. diag.warning or "")
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Neo-tree",
              highlight = "Directory",
              text_align = "left",
            },
            {
              filetype = "snacks_layout_box",
            },
          },
        },
        -- 修改背景色统一
        highlights = {
          fill = { bg = bg },
          background = { bg = bg },
          close_button = { bg = bg },
          tab_separator = { bg = bg },
          tab_separator_selected = { bg = bg },

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
          warning_diagnostic = { bg = bg },
          error = { bg = bg },
          error_diagnostic = { bg = bg },
          modified = { bg = bg },
          duplicate = { bg = bg },
          separator = { fg = bg, bg = bg },
          pick = { bg = bg },
          offset_separator = { bg = bg },
          trunc_marker = { bg = bg },
        },
      }
    end,
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
      { "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
      { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
      { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
    },
  },
  {
    -- 下方状态栏
    "nvim-lualine/lualine.nvim",
    -- enabled = vim.g.lualine or false,
    event = vim.g.lualine and "VeryLazy" or {},
    opts = function()
      local icons = OwnUtil.icons

      local opts = {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          },
          lualine_x = {
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = function() return { fg = Snacks.util.color("Statement") } end,
            },
            -- stylua: ignore
            {
              function() return " " .. require("dap").status() end,
              cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
              color = function() return { fg = Snacks.util.color("Debug") } end,
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return {
                    added = gitsigns.added,
                    modified = gitsigns.changed,
                    removed = gitsigns.removed,
                  }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 1 } },
          },
          lualine_z = {
            { "location", padding = { left = 0, right = 1 } },
          },
        },
        extensions = { "neo-tree", "lazy", "fzf", "mason", "symbols-outline" },
      }

      return opts
    end,
  },
}

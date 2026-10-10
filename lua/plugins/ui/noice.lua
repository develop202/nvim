-- 通知
local noice_cmdline_min_width = 60

if OwnUtil.sys.is_termux() then
  -- 通知
  noice_cmdline_min_width = 30
end

return {
  {
    -- 通知
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
      views = {
        -- cmdline宽度
        cmdline_popup = {
          size = {
            min_width = noice_cmdline_min_width,
          },
        },
        -- cmdline补全框宽度
        cmdline_popupmenu = {
          size = {
            width = noice_cmdline_min_width,
          },
        },
        mini = {
          size = {
            max_height = 3,
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>sn", "", desc = "+noice" },
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All", },
      { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>", function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end, silent = true, expr = true, desc = "Scroll Forward", mode = { "i", "n", "s" } },
      { "<c-b>", function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end, silent = true, expr = true, desc = "Scroll Backward", mode = { "i", "n", "s" } },
    },
  },
}

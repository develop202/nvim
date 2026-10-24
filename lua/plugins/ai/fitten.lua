return {
  {
    "luozhiya/fittencode.nvim",
    cmd = "FittenCode",
    event = "InsertEnter",
    opts = {
      keymaps = {
        inline = {
          inccmp = {
            ["accept_all"] = "<C-Down>",
            ["accept_next_line"] = "<C-Right>",
            ["accept_next_word"] = "<C-Up>",
          },
        },
      },
      delay_completion = {
        delaytime = 2000,
      },
      inline_completion = {
        -- Enable inline code completion.
        enable = false,
      },
    },
    keys = {
      {
        "<leader>aifc",
        "<cmd>FittenCode toggle_completions<cr>",
        desc = "[FittenCode] toggle completions",
      },
    },
  },
}

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
        delaytime = 1000,
      },
    },
  },
}

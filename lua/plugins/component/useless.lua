return {
  {
    "Eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      {
        "<leader>fm",
        function()
          math.randomseed(vim.uv.hrtime() % 2147483647) -- 避免每次随机序列相同
          local cmds = { "make_it_rain", "game_of_life" }

          vim.cmd("CellularAutomaton " .. cmds[math.random(#cmds)])
        end,
        desc = "cellular automaton animations",
      },
    },
  },
}

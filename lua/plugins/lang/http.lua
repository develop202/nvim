return {
  {
    "mistweaverco/kulala.nvim",
    brains = "main",
    opts = function(_, opts)
      if OwnUtil.sys.is_termux() then
        opts.split_direction = "horizontal"
      end
    end,
  },
}

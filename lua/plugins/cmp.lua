return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.appearance = opts.appearance or {}
      opts.appearance.kind_icons = vim.tbl_extend("keep", {
        Color = "󱓻 ", -- Use block instead of icon for color items to make swatches more usable
      }, LazyVim.config.icons.kinds)
    end,
  },
}

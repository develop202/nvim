local window_width = 25
if OwnUtil.sys.is_termux() then
  window_width = 60
end
return {
  "hedyhli/outline.nvim",
  cmd = "Outline",
  opts = function(_, opts)
    opts.outline_window = {
      width = window_width,
    }
    opts.providers = {
      lsp = {
        -- 忽略lsp
        blacklist_clients = { "spring-boot", "ruff" },
      },
    }
    local icons = require("outline.config").defaults.symbols.icons
    for key, _ in pairs(icons) do
      -- 使用自己的图标
      icons[key].icon = OwnUtil.icons.kinds[key] or icons[key].icon
    end

    opts.keymaps = {
      goto_location = "o",
      fold_toggle = "<CR>",
      peek_location = "p",
    }
  end,
}

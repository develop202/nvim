if OwnUtil.sys.is_termux() then
  -- 控制cmp补全框宽度
  vim.g.cmp_widths = {
    abbr = 15,
    menu = 30,
  }
end

local truncate = true

local sources = {
  path = {
    max_depth = 16,
  },
}
if OwnUtil.sys.is_termux() then
  truncate = false
  sources.path.max_depth = 1
end
return {
  {
    -- 面包屑导航
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
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
}

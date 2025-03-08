---@class util
---@field sys util.sys
---@field icons util.icons
---@field mini_icons util.mini_icons
local M = {}

-- 使用元表为全局变量添加字段
setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("util." .. k)
    return t[k]
  end,
})

return M

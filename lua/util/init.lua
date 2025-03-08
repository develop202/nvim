---@class util
---@field sys util.sys
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

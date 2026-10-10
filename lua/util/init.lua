---@class util
---@field sys util.sys
---@field icons util.icons
---@field utils util.utils
---@field lang util.lang
local M = {}

-- 使用元表为全局变量添加字段
setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("util." .. k)
    return t[k]
  end,
})

M.statuscolumn = function()
  return require("snacks.statuscolumn").get()
end

return M

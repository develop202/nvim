---@class util.sys
local M = {}

--- 判断termux环境
---@return boolean
M.is_termux = function()
  return os.getenv("HOME") == "/data/data/com.termux/files/home"
end

return M

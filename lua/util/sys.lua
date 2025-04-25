---@class util.sys
local M = {}

--- 判断termux环境
---@return boolean
M.is_termux = function()
  return os.getenv("HOME") == "/data/data/com.termux/files/home"
end

--- 判断系统,全部小写。win|mac|linux|unknown
---@return string
M.get_os_type = function()
  -- Check for Windows
  if os.getenv("OS") and os.getenv("OS"):lower():find("windows") then
    return "win"
  end

  -- Check for macOS
  if os.getenv("OSTYPE") and os.getenv("OSTYPE"):lower():find("darwin") then
    return "mac"
  end

  -- Check for Linux using uname command
  local f = io.popen("uname -s", "r")
  if f then
    local uname = f:read("*a")
    f:close()
    if uname and uname:lower():find("linux") then
      return "linux"
    end
  end
  return "unknown"
end

return M

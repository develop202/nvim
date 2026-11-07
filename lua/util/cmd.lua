--- 命令
---@class util.cmd
local M = {}

--- Java启动命令
---@param version? number 版本号
---@return string Java命令
M.java_bin = function(version)
  if version == nil then
    version = 17
  end
  -- Java启动命令
  local java_bin = "java"
  if vim.env["JAVA_" .. version .. "_HOME"] then
    java_bin = vim.env["JAVA_" .. version .. "_HOME"] .. "/bin/java"
  elseif vim.env["JAVA_HOME"] then
    java_bin = vim.env["JAVA_HOME"] .. "/bin/java"
  end
  return java_bin
end

return M

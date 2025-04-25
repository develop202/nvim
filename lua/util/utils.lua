---@class util.utils
local M = {}

M.ft = {}
M.cmd = {}

M.ft.cmp_html_css_ft = {
  "html",
  "htmldjango",
  "tsx",
  "jsx",
  "erb",
  "svelte",
  "vue",
  "blade",
  "php",
  "templ",
  "astro",
}
M.ft.show_color_ft = {
  -- 解包
  unpack(M.ft.cmp_html_css_ft),
  "scss",
  "css",
  "less",
  "javascript",
  "typescript",
  "json",
  "yaml",
  "markdown",
  "lua",
  "go",
  "kotlin",
  "dart",
}

M.cmd.java_bin = function()
  -- Java启动命令
  local java_bin = "java"
  if vim.env["JAVA_HOME"] then
    java_bin = vim.env["JAVA_HOME"] .. "/bin/java"
  end
  if vim.env["JAVA21_HOME"] then
    java_bin = vim.env["JAVA21_HOME"] .. "/bin/java"
  end
  return java_bin
end

return M

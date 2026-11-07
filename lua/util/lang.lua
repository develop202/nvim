---@class util.lang
local M = {}

--- 文件类型
M.ft = {}

--- 需要加载插件html-css-cmp的文件类型
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
--- 需要显示颜色的文件类型
M.ft.show_color_ft = {
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

-- 合并数组,合并到第一个数组里面
vim.list_extend(M.ft.show_color_ft, M.ft.cmp_html_css_ft)

M.java = {}

M.java.is_spring_boot_project = function(dir)
  dir = dir or vim.fn.getcwd()
  local spring_boot_markers = {
    "application.yml",
    "application.yaml",
    "application.properties",
    "bootstrap.yml",
    "bootstrap.yaml",
    "bootstrap.properties",
  }

  local found = vim.fs.find(function(name, path)
    for _, marker in pairs(spring_boot_markers) do
      if name == marker then
        return path:match("src[/\\]main[/\\]resources$") ~= nil
      end
    end
    return false
  end, {
    path = dir,
    type = "file",
  })
  if #found > 0 then
    return true
  end
  return false
end

M.treesitter = {
  "bash",
  "c",
  "cpp",
  "css",
  "dart",
  "diff",
  "dockerfile",
  "dtd",
  "go",
  "gomod",
  "gosum",
  "gowork",
  "graphql",
  "groovy",
  "html",
  "http",
  "java",
  "javascript",
  "jsdoc",
  "json",
  "json5",
  "kotlin",
  "kulala_http",
  "lua",
  "luadoc",
  "luap",
  "markdown",
  "markdown_inline",
  "ninja",
  "php",
  "php_only",
  "printf",
  "python",
  "query",
  "regex",
  "rst",
  "scss",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "vue",
  "xml",
  "yaml",
}

M.groovy = {}

-- 辅助函数：查找 Mason 安装的工具路径
local function find_tool(tool)
  -- 优先从系统 PATH 查找
  local path = vim.fn.exepath(tool)
  if path ~= "" then
    return path
  end
  -- 回退到 Mason 默认 bin 目录
  local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/" .. tool
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end
  return tool -- 返回原始命令名，让系统自行解析
end

-- 格式化函数：两步 npm-groovy-lint，先缩进1后缩进2，带超时
M.groovy.format_groovy_two_step = function()
  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    vim.notify("当前缓冲区没有文件名", vim.log.levels.WARN)
    return
  end

  -- 获取 npm-groovy-lint 可执行文件路径
  local groovy_lint = find_tool("npm-groovy-lint")

  -- 超时时间（秒），可根据需要调整
  local timeout_seconds = 10

  -- 构造两步命令，使用 timeout 限制每次执行时间
  -- 第一步：缩进1格
  local cmd_step1 = string.format(
    "timeout %ds node %s --fix --config '"
      .. vim.fn.stdpath("config")
      .. "/after/ftplugin/asset/groovy/lint.json"
      .. "' %s",
    timeout_seconds,
    groovy_lint,
    vim.fn.shellescape(filepath)
  )
  -- 第二步：缩进2格（依赖第一步完成）
  local cmd_step2 = string.format(
    "timeout %ds node %s --fix --config '"
      .. vim.fn.stdpath("config")
      .. "/after/ftplugin/asset/groovy/lint2.json"
      .. "' %s",
    timeout_seconds,
    groovy_lint,
    vim.fn.shellescape(filepath)
  )

  -- 用 && 确保顺序执行（先1后2）
  local full_cmd = cmd_step1 .. " && sleep 1"

  -- 同步执行，阻塞 Neovim 直到完成或超时
  local output = vim.fn.system(full_cmd)
  local exit_code = vim.v.shell_error

  -- 同步执行，阻塞 Neovim 直到完成或超时
  output = vim.fn.system(cmd_step2)
  exit_code = vim.v.shell_error

  if exit_code ~= 1 then
    vim.notify("Groovy 格式化失败（退出码 " .. exit_code .. "）:\n" .. output, vim.log.levels.ERROR)
  else
    vim.notify("Groovy 格式化完成", vim.log.levels.INFO)
    -- 重新加载文件以反映磁盘更改（因为 npm-groovy-lint 直接修改文件）
    vim.cmd("edit!")
  end
  -- end
end

return M

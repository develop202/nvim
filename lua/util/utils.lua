---@class util.utils
local M = {}

--- 文件类型
M.ft = {}
--- 命令
M.cmd = {}
-- 启动页
M.dashboard = {}

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

--- Java启动命令
---@return string Java命令
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

--- 部分lsp不支持termux或编译过慢
--- 直接本地安装后链接
---@param mason_registry MasonRegistry mason注册表
---@param server_name string lsp名称
M.termux_use_local_lsp = function(mason_registry, server_name)
  if OwnUtil.sys.is_termux() then
    if not mason_registry.is_installed(server_name) then
      -- 若本地安装了lsp
      if vim.fn.executable(server_name) == 1 then
        -- 链接执行文件
        vim.cmd(
          string.format(
            "silent! !ln -sf %s %s",
            os.getenv("HOME") .. "/../usr/bin/" .. server_name,
            vim.fn.stdpath("data") .. "/mason/bin/" .. server_name
          )
        )
        -- 创建lsp目录
        vim.cmd(string.format("silent! !mkdir -p %s", vim.fn.stdpath("data") .. "/mason/packages/" .. server_name))
        vim.notify(server_name .. "链接完成，请重启Neovim！")
      else
        vim.notify("未安装" .. server_name .. "!", vim.log.levels.WARN)
      end
    end
  end
end

--- termux端时修改文件某行文本，性能挺好
---@param file_path string 要修改的文件路径
---@param line_number integer 要修改的行号（从 1 开始）
---@param new_line_content string 新的行内容
M.termux_change_file_line = function(file_path, line_number, new_line_content)
  -- 打开文件以读取模式
  local file = io.open(file_path, "r")
  if not file then
    vim.notify("无法打开文件: " .. file_path)
    return
  end

  -- 读取文件的所有行到一个表中
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()

  -- 检查行号是否在有效范围内
  if line_number > 0 and line_number <= #lines then
    -- 修改指定行的内容
    lines[line_number] = new_line_content
  else
    vim.notify("无效的行号")
    return
  end
  -- 打开文件以写入模式
  file = io.open(file_path, "w")
  if not file then
    vim.notify("无法打开文件以写入: " .. file_path)
    return
  end

  -- 将修改后的行写回到文件中
  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()

  -- print("文件已成功修改")
end

M.dashboard.preset = {
  header = table.concat({
    -- 这样不太直观，看着挺丑的
    "                 __                ",
    "  ___    __  __ /\\_\\    ___ ___    ",
    " / _ `\\ /\\ \\/\\ \\\\/\\ \\  / __` __`\\  ",
    "/\\ \\/\\ \\\\ \\ \\_/ |\\ \\ \\/\\ \\/\\ \\/\\ \\ ",
    "\\ \\_\\ \\_\\\\ \\___/  \\ \\_\\ \\_\\ \\_\\ \\_\\",
    " \\/_/\\/_/ \\/__/    \\/_/\\/_/\\/_/\\/_/",
  }, "\n"),
}

--- termux 边距相同的宽度
---@return number
M.termux_dash_width = function()
  local width = vim.o.columns
  local dash_width = math.floor(0.8 * width)
  if OwnUtil.sys.is_termux() then
    -- 减少启动页面整体宽度
    if width < 75 then
      -- 让两边边距相同
      if (width - dash_width) % 2 == 1 then
        dash_width = dash_width + 1
      end
    end
  end
  return dash_width
end

return M

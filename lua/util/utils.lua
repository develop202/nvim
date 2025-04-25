---@class util.utils
local M = {}

--- 文件类型
M.ft = {}
--- 命令
M.cmd = {}

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

-- 合并数组
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
            "!ln -sf %s %s",
            os.getenv("HOME") .. "/../usr/bin/" .. server_name,
            vim.fn.stdpath("data") .. "/mason/bin/" .. server_name
          )
        )
        -- 创建lsp目录
        vim.cmd(string.format("!mkdir -p %s", vim.fn.stdpath("data") .. "/mason/packages/" .. server_name))
        vim.notify(server_name .. "安装完成，请重启Neovim！")
      else
        vim.notify("未安装" .. server_name .. "!", vim.log.levels.WARN)
      end
    end
  end
end

return M

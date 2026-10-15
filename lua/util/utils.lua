---@class util.utils
local M = {}

--- 文件类型
M.ft = {}
--- 命令
M.cmd = {}
-- 启动页
M.dashboard = {}
-- lsp相关
M.lsp = {}
-- 高亮
M.hl = {}

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
  if vim.env["JAVA_21_HOME"] then
    java_bin = vim.env["JAVA_21_HOME"] .. "/bin/java"
  end
  return java_bin
end

--- 部分lsp不支持termux或编译过慢
--- 直接本地安装后链接
--- mason_registry MasonRegistry mason注册表
--- server_name string lsp名称
M.termux_use_local_lsp = function(mason_registry, server_name)
  if OwnUtil.sys.is_termux() then
    if not mason_registry.is_installed(server_name) then
      -- 若本地安装了lsp
      if vim.fn.executable(server_name) == 1 then
        -- 链接执行文件
        vim.cmd(
          string.format(
            "silent! !ln -sf %s %s",
            vim.env["HOME"] .. "/../usr/bin/" .. server_name,
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

--- 强制修改lsp最新版本号
---@param lspname string lsp名字 全称
---@param version string 最新版本
M.update_lsp_version_when_not_newest = function(lspname, version)
  if not lspname or not version then
    vim.notify("参数缺失，操作忽略")
    return
  end

  local filepath = vim.env["HOME"] .. "/.local/share/nvim/mason/packages/" .. lspname .. "/mason-receipt.json"
  local content = '{"name":"'
    .. lspname
    .. '","links":{"share":{},"bin":{"'
    .. lspname
    .. '":"'
    .. lspname
    .. '"},"opt":{}},"secondary_sources":[],"metrics":{"start_time":1745458740322,"completion_time":1745458799444},"schema_version":"1.1","primary_source":{"type":"registry+v1","id":"pkg:generic/'
    .. lspname
    .. "@"
    .. version
    .. '"}}'

  M.write_file(filepath, content)

  vim.notify("修改完成")
end

--- 覆盖写入文件内容
---@param filepath string 文件路径
---@param content string 写入内容
M.write_file = function(filepath, content)
  local file = assert(io.open(filepath, "w"))
  file:write(content)
  file:flush()
  file:close()
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

local patch = {
  -- [""] = {
  --   { search = '', replace = '' },
  -- },
  ["persistence"] = { -- 针对 persistence/init.lua
    {
      search = "function M.select%(%)",
      replace = "local function exist_dir(dir, session) if not vim.uv.fs_stat(dir) then os.remove(session) return false end return true end \nlocal function handle_selected(opts)",
    },
    { search = 'prompt = "Select a session: ",', replace = "prompt = opts.prompt," },
    { search = "      vim.fn.chdir%(item%.dir%)", replace = "opts.handler(item)" },
    {
      search = "      M.load%(%)",
      replace = "",
    },
    -- 选择和删除
    {
      search = "--- g",
      replace = 'function M.select() handle_selected({ prompt = "Select a session: ", handler = function(item) local ok, _ = pcall(function() vim.fn.chdir(item.dir) M.load() end) if not ok then os.remove(item.session) print("Deleted not exist session " .. item.dir .. ".") end end, }) end \nfunction M.delete() handle_selected({ prompt = "Delete a session: ", handler = function(item) os.remove(item.session) print("Deleted session " .. item.session) end, }) end\n--- g',
    },
    {
      search = "if not have%[dir%] then",
      replace = "if exist_dir%(dir,session%) and not have%[dir%] then",
    },
  },

  ["java-deps.views.parser"] = {
    -- 去空格
    { search = 'icon .. " " .. node.label', replace = "icon .. node.label" },
    {
      search = "hl_icon%.icon",
      replace = 'hl_icon.icon .. " "',
    },
    {
      search = 'line%[index%] = line%[index%] %.%. " "',
      replace = 'local suffix = " " if line[index] == " " or line[index] == " " then suffix = "" end line[index] = line[index] .. suffix',
    },
  },

  -- 去空格
  ["outline.sidebar"] = {
    { search = "line .. ' ' .. node.name", replace = "line .. node.name" },
    { search = "hl_end %+ 1", replace = "hl_end" },
    -- { search = "", replace = "" },
  },
  -- vue文件请求outline特殊处理
  ["outline.providers.nvim-lsp"] = {
    {
      search = "return use_client",
      replace = "  if vim.o.filetype == 'vue' and use_client.name =='vtsls' and #clients >=2 then use_client = clients[2] end \n return use_client",
    },
  },
}

M.perform_surgery = function(modname)
  -- 3. 定义你需要“手术”的模块名单及其对应的补丁规则
  local patches = patch

  -- 4. 检查当前加载的模块是否在补丁名单中
  if patches[modname] then
    -- --- 核心修复：改用 Neovim 的 runtime 搜索机制 ---
    local subpath = "lua/" .. modname:gsub("%.", "/") .. ".lua"
    local init_subpath = "lua/" .. modname:gsub("%.", "/") .. "/init.lua"

    local candidates = vim.api.nvim_get_runtime_file(subpath, false)
    if #candidates == 0 then
      candidates = vim.api.nvim_get_runtime_file(init_subpath, false)
    end

    local path = candidates[1] -- 取找到的第一个路径

    if path then
      local f = io.open(path, "r")
      if f then
        local content = f:read("*all") -- 6. 将源码全部读入内存（字符串）
        f:close()

        -- 7. 执行字符串替换（核心手术过程）
        for _, p in ipairs(patches[modname]) do
          content = content:gsub(p.search, p.replace)
        end
        -- vim.notify(content)

        -- 8. 使用 load 函数将修改后的字符串编译成 Lua 可执行函数
        local chunk, err = load(content, "@" .. path)
        if not chunk then
          error("补丁编译失败: " .. err)
        end
        return chunk -- 返回给 Lua 引擎执行
      end
    end
  end

  -- 9. 如果不是我们要改的模块，直接交给原有的加载器处理
  return nil
end

-- 定义补丁函数
local patch_dadbod_ui = function()
  -- 1. 获取插件文件的物理路径
  local files = vim.api.nvim_get_runtime_file("autoload/db_ui/drawer.vim", false)
  if #files == 0 then
    return
  end
  local path = files[1]

  -- 2. 读取源码
  local f = io.open(path, "r")
  if not f then
    return
  end
  local content = f:read("*all")
  f:close()

  -- 1. 核心修复：将所有的 function 替换为 function!
  -- 使用 gsub 的模式匹配，确保不会把 function! 变成 function!!
  -- 这个正则匹配 "function" 后面跟着空格，但中间没有感叹号的情况
  content = content:gsub("function%s+", "function! ")
  -- 兜底：如果源码里本来就有 function!，上面的操作可能会产生 function!!，这里修回来
  content = content:gsub("function!!", "function!")
  content = content:gsub("endfunction!", "endfunction\n")
  -- content = content:gsub("function! db_ui#drawer#get%(%)", "function db_ui#drawer#get()")

  -- 3. 手术：替换你想要的那一行
  -- 注意：Vimscript 里的引号比较多，gsub 匹配时要小心转义
  local old_pattern =
    'let content = map%(copy%(self%.content%), \'repeat%(" ", shiftwidth%(%) %* v:val%.level%)%.v:val%.icon%.%(!empty%(v:val%.icon%) %? " " : ""%)%.v:val%.label\'%)'

  -- 你想要替换成的新行代码
  local new_line =
    "  let content = map(copy(self.content), 'repeat(\" \", shiftwidth() * v:val.level).v:val.icon.v:val.label')"

  -- vim.notify(content)
  local new_content, count = content:gsub(old_pattern, new_line)

  if count > 0 then
    -- 4. 重新注入内存执行，覆盖原有定义
    -- 我们使用一个临时变量防止无限递归（虽然 SourcePost 重新 exec 通常不会触发 SourcePost，但稳妥起见）
    vim.g.db_ui_patching = true
    vim.api.nvim_exec2(new_content, {
      output = false,
    })
    vim.g.db_ui_patching = false

    -- vim.schedule(function()
    --   vim.notify("Dadbod-UI 内存补丁已应用", vim.log.levels.INFO)
    -- end)
  end
end

M.patch_vim_plugin = function()
  patch_dadbod_ui()
end

M.treesitter_context_object_attach = function(buf)
  local moves = {
    goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
    goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
  }

  for method, keymaps in pairs(moves) do
    for key, query in pairs(keymaps) do
      local queries = type(query) == "table" and query or { query }
      local parts = {}
      for _, q in ipairs(queries) do
        local part = q:gsub("@", ""):gsub("%..*", "")
        part = part:sub(1, 1):upper() .. part:sub(2)
        table.insert(parts, part)
      end
      local desc = table.concat(parts, " or ")
      desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
      desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
      vim.keymap.set({ "n", "x", "o" }, key, function()
        if vim.wo.diff and key:find("[cC]") then
          return vim.cmd("normal! " .. key)
        end
        require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
      end, {
        buffer = buf,
        desc = desc,
        silent = true,
      })
    end
  end
end

--- intellij系列Termux端适配
---@param lsp_install_path string lsp安装根目录 需子目录是bin
M.lsp.intellij_termux_adapted = function(lsp_install_path)
  local ok_file_path = lsp_install_path .. "/ok"
  if OwnUtil.sys.is_termux() and not vim.uv.fs_stat(ok_file_path) then
    local server_path = lsp_install_path .. "/bin/intellij-server"
    vim.notify(server_path)
    vim.cmd("!grun --configure " .. server_path)

    local file = io.open(lsp_install_path .. "/bin/intellij-server.vmoptions", "r+")
    if file then
      local content = file:read("*a")
      content = content:gsub("512", "256")
      content = content:gsub("128", "512")
      content = content:gsub("2048", "512")

      content = content
        .. "\n"
        .. "-Djava.io.tmpdir=/data/data/com.termux/files/usr/tmp\n"
        .. "-Djdk.lang.Process.launchMechanism=fork"

      file:seek("set", 0)
      file:write(content)
      file:close()

      local f = io.open(ok_file_path, "w")
      if f then
        f:close()
      end
    end
  end
end

-- 兼容封装：统一返回 { fg, bg, sp, italic, bold, ... }
M.hl.get_hl = function(name)
  local raw, hl

  if vim.api.nvim_get_hl then
    -- 0.9+：字段已经是 fg / bg / sp / italic / bold 等，直接就是统一格式
    raw = vim.api.nvim_get_hl(0, { name = name })
    -- if name == "GruvboxBg0" then
    --   vim.cmd("hi GruvboxBg0")
    -- end
    return raw
  end

  -- 0.9 以下：返回的是 foreground / background / special / italic / bold ...
  ---@diagnostic disable-next-line: deprecated
  raw = vim.api.nvim_get_hl_by_name(name, true)
  hl = {}
  for k, v in pairs(raw) do
    if k == "foreground" then
      hl.fg = v
    elseif k == "background" then
      hl.bg = v
    elseif k == "special" then
      hl.sp = v
    else
      -- italic / bold / underline / reverse / strikethrough 等字段名一致
      hl[k] = v
    end
  end
  return hl
end

return M

--- @class util.patch
local M = {}
M.patches = {
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

  ["intellij-lsp.client"] = {
    {
      search = "on_attach = function%(client, bufnr%)",
      replace = 'on_attach = function(client, bufnr)\n      require("intellij-lsp").config.on_attach(client, bufnr)',
    },
  },
  ["intellij-lsp"] = {
    {
      search = "M.config = vim%.tbl_extend%('force', {",
      replace = "M.config = vim.tbl_extend('force', {\n    on_attach = function(client, bufnr) end,",
    },
  },

  ["kulala.config.parser"] = {
    {
      search = [[        return
      end
      build_parser%(setup_finish%)
    end%)]],
      replace = [[      end
    end)
    build_parser(setup_finish)]],
    },
  },

  -- 使用lualine时
  ["kulala"] = {
    {
      search = [[  local ok, lualine = pcall(require, "lualine")
  if ok and lualine then lualine.setup() end]],
      replace = [[if vim.g.lualine then
    local ok, lualine = pcall(require, "lualine")
    if ok and lualine then lualine.setup() end
  end]],
    },
  },

  ["spring_boot"] = {
    {
      search = [[  if pcall(require, "jdtls") then
    -- Loading nvim-jdtls just installed its own equivalent handler. Prefer it
    -- rather than clobbering it.
    return]],
      replace = [[  if not vim.g.intellij then
    if pcall(require, "jdtls") then
      -- Loading nvim-jdtls just installed its own equivalent handler. Prefer it
      -- rather than clobbering it.
      return
    end]],
    },
  },

  ["pretty_hover"] = {
    {
      search = [[local client = h_util.get_current_active_client()
	local hover_support_present = client and client.capabilities.textDocument.hover

	if not client or not hover_support_present then
		vim.notify("There is no client for this filetype or the client does not support the hover capability.", vim.log.levels.WARN)
		return
	end]],
      replace = [[local clients = vim.lsp.get_clients({ bufnr = 0 })
	local hover_support_present = false

	for _, client in ipairs(clients) do
		if client:supports_method("textDocument/hover", 0) then
			hover_support_present = true
			break
		end
	end

	if #clients == 0 or not hover_support_present then
		vim.notify(
			"There is no client for this filetype or the client does not support the hover capability.",
			vim.log.levels.WARN
		)
		return
	end]],
    },
  },

  ["spring-initializr.telescope.telescope"] = {
    {
      search = [[prompt_position = "top",
        width = 0.5,
        height = 0.6,]],
      replace = [[prompt_position = "bottom",
        width = 0.9,
        height = 0.9,]],
    },
  },
  ["spring-initializr.ui.components.dependencies.dependencies_display"] = {
    {
      search = [[width = 40]],
      replace = [[width = 10]],
    },
  },
  -- 总宽度
  ["spring-initializr.ui.layout.layout"] = {
    { search = [[70]], replace = [[95]] },
  },

  ["spring-initializr.ui.layout.panel_builder"] = {
    {
      search = [[inputs,
    }, { dir = "col", size = "50]],
      replace = [[inputs,
    }, { dir = "col", size = "70]],
    },
    {
      search = [[grow = 1 }%),
    }, { dir = "col", size = "50]],
      replace = [[grow = 1 }%),
    }, { dir = "col", size = "30]],
    },
  },
}

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

-- lua 插件patch
M.patch_lua_plugin = function(modname)
  -- 3. 定义你需要“手术”的模块名单及其对应的补丁规则
  local patches = OwnUtil.patch.patches

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
        for i, p in ipairs(patches[modname]) do
          local search = p.search
          --- 检测 Lua pattern 是否合法
          local function is_valid_pattern(pattern)
            local ok = pcall(string.find, "", pattern)
            return ok
          end

          local function escape_pattern(s)
            return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
          end
          if not is_valid_pattern(search) then
            --- 把任意字符串转义成只匹配它自身的合法 pattern
            search = escape_pattern(search)
          end

          local patched_content, count = content:gsub(search, p.replace)
          if count > 0 then
            content = patched_content
          else
            -- [[]]这种类型无法判断合法性
            search = escape_pattern(search)
            patched_content, count = content:gsub(search, p.replace)
            if count > 0 then
              content = patched_content
            else
              error("\n" .. modname .. ": patch failed.\nindex = " .. i)
            end
          end
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

-- vim 插件patch
M.patch_vim_plugin = function()
  patch_dadbod_ui()
end

return M

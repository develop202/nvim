-- spring_boot_bridge.lua
--
-- 将 spring-boot-ls 与 intellij-server 桥接起来；不负责启动任何 LSP。
--
-- 协议流程：
--   1. 接收 Spring LS 的 sts/addClasspathListener 请求，保存 callbackCommandId。
--   2. 向 IntelliJ Server 执行 getSpringToolsClasspath，读取项目类路径。
--   3. 先结束监听注册请求，再向 Spring LS 执行 callbackCommandId，推送六个项目字段。
--   4. sts/javaLocation 转发给 getSpringToolsJavaLocation；其余 Java 请求保留原扩展的空结果行为。
--
-- 必须覆盖 Spring 客户端自己的 handlers：spring-boot.nvim 设置的 client.handlers
-- 优先于 vim.lsp.handlers 全局处理器，否则旧的 JDTLS 转发逻辑仍会生效。

local M = {}

local config = {
  intellij_client_names = { "intellij-server", "intellij_server", "Java and Kotlin" },
  spring_client_names = { "spring-boot", "spring-boot-ls", "spring_boot" },
  request_timeout = 10000,
  intellij_wait_timeout = 2000,
  retry_delays = { 2000, 5000, 10000, 20000 },
  refresh_on_build_file_write = true,
  build_file_refresh_delay = 2500,
  auto_enable_classpath_listening = true,
  debug = false,
}

local METHOD = {
  add_listener = "sts/addClasspathListener",
  remove_listener = "sts/removeClasspathListener",
  java_location = "sts/javaLocation",
  enable_listening = "sts.vscode-spring-boot.enableClasspathListening",
  get_classpath = "getSpringToolsClasspath",
  get_java_location = "getSpringToolsJavaLocation",
}

-- listeners 按 Spring LS 提供的回调命令 ID 保存。
local listeners, enabled_clients, patched_clients = {}, {}, {}
local handlers_installed, commands_installed = false, false
local lsp_group, build_group

local function log(message, level)
  vim.schedule(function()
    vim.notify("[spring_boot_bridge] " .. tostring(message), level or vim.log.levels.INFO)
  end)
end

local function debug(message)
  if config.debug then log(message, vim.log.levels.DEBUG) end
end

local function rpc_error(message, code)
  -- 让 Spring LS 收到真正的 LSP 错误，以便它选择自己的回退行为。
  if vim.lsp.rpc_response_error then
    return vim.lsp.rpc_response_error(code or -32603, tostring(message))
  end
  return { code = code or -32603, message = tostring(message) }
end

local function is_null(value)
  return value == nil or value == vim.NIL
end

local function json_value(value)
  -- 保留 JSON 数组里缺失字段的占位；Lua nil 会让数组元素消失。
  return value == nil and vim.NIL or value
end

local function normalize(name)
  return tostring(name or ""):lower():gsub("[^%w]", "")
end

local function has_command(client, command)
  local provider = client and client.server_capabilities and client.server_capabilities.executeCommandProvider
  return type(provider) == "table"
    and type(provider.commands) == "table"
    and vim.tbl_contains(provider.commands, command)
end

local function find_client(names, predicate)
  local clients = vim.lsp.get_clients()
  for _, wanted in ipairs(names or {}) do
    for _, client in ipairs(clients) do
      if normalize(client.name) == normalize(wanted) then return client end
    end
  end
  if predicate then
    for _, client in ipairs(clients) do
      if predicate(normalize(client.name), client) then return client end
    end
  end
end

local function intellij_client()
  return find_client(config.intellij_client_names, function(name)
    return name:find("intellijserver", 1, true) ~= nil
  end)
end

local function spring_client()
  return find_client(config.spring_client_names, function(name, client)
    return has_command(client, METHOD.enable_listening)
      or (name:find("spring", 1, true) and name:find("boot", 1, true))
  end)
end

local function workspace_root(client)
  local folders = client and client.workspace_folders
  if folders and folders[1] and folders[1].uri then
    local ok, path = pcall(vim.uri_to_fname, folders[1].uri)
    if ok and path and path ~= "" then return path end
  end
  local root = client and (client.root_dir or (client.config and client.config.root_dir))
  return type(root) == "string" and root ~= "" and root or vim.fn.getcwd()
end

local function wait_for_intellij()
  local function ready()
    local client = intellij_client()
    return client and client.initialized and not client:is_stopped()
      and has_command(client, METHOD.get_classpath)
  end

  if not ready() and config.intellij_wait_timeout > 0 then
    vim.wait(config.intellij_wait_timeout, ready, 50)
  end

  local client = intellij_client()
  if not client then return nil, "IntelliJ Server client not found" end
  if not client.initialized or client:is_stopped() then
    return nil, "IntelliJ Server client is not initialized"
  end
  if not has_command(client, METHOD.get_classpath) then
    return nil, "IntelliJ Server does not advertise " .. METHOD.get_classpath
  end
  return client
end

-- 对指定 LSP 客户端执行标准 workspace/executeCommand。
local function execute_command(client, command, arguments)
  if not client or client:is_stopped() then return nil, "target LSP client is not running" end

  local response, err = client:request_sync("workspace/executeCommand", {
    command = command,
    arguments = arguments or {},
  }, config.request_timeout, 0)

  if not response then return nil, command .. " failed: " .. tostring(err or "no response") end
  if response.err then
    return nil, command .. " failed: " .. tostring(response.err.message or vim.inspect(response.err))
  end
  return response.result
end

local function read_classpath(client)
  local result, err = execute_command(client, METHOD.get_classpath, { workspace_root(client) })
  if err then return nil, err end
  if is_null(result) then return {}, nil end -- null 表示当前没有可推送的项目。
  if type(result) ~= "table" then
    return nil, METHOD.get_classpath .. " returned neither array nor null"
  end
  return result
end

-- 通过 Spring LS 提供的动态命令 ID 回传一个项目的类路径数据。
local function push_project(callback_id, listener, project)
  local spring = vim.lsp.get_client_by_id(listener.spring_client_id)
  if not spring or spring:is_stopped() then
    listeners[callback_id] = nil
    return
  end
  if type(project) ~= "table" or is_null(project.projectUri) then
    debug("skip invalid project from IntelliJ classpath response")
    return
  end

  -- 参数顺序对应 VS Code 版本：projectUri、name、deleted、classpath、projectBuild、javaCoreOptions。
  local ok, err = spring:request("workspace/executeCommand", {
    command = callback_id,
    arguments = {
      json_value(project.projectUri),
      json_value(project.name),
      json_value(project.deleted),
      json_value(project.classpath),
      json_value(project.projectBuild),
      json_value(project.javaCoreOptions),
    },
  }, function(request_err)
    if request_err then
      log("classpath callback failed: " .. tostring(request_err.message or vim.inspect(request_err)), vim.log.levels.WARN)
    else
      debug("classpath sent for " .. tostring(project.name or project.projectUri))
    end
  end, 0)

  if not ok then log("could not send classpath callback " .. callback_id, vim.log.levels.WARN) end
end

local function push_projects(callback_id, listener, projects)
  for _, project in ipairs(projects or {}) do push_project(callback_id, listener, project) end
end

-- 项目刚启动时类路径可能暂时为空；有限重试，避免永久轮询。
local function retry_empty_classpath(callback_id, attempt)
  local delay = config.retry_delays[attempt]
  if not delay then return end

  vim.defer_fn(function()
    local listener = listeners[callback_id]
    if not listener then return end

    local spring = vim.lsp.get_client_by_id(listener.spring_client_id)
    if not spring or spring:is_stopped() then listeners[callback_id] = nil; return end

    local intellij = wait_for_intellij()
    if not intellij then retry_empty_classpath(callback_id, attempt + 1); return end

    local projects, err = read_classpath(intellij)
    if err then
      debug("classpath retry failed: " .. err)
      retry_empty_classpath(callback_id, attempt + 1)
    elseif #projects > 0 then
      push_projects(callback_id, listener, projects)
    else
      retry_empty_classpath(callback_id, attempt + 1)
    end
  end, delay)
end

-- Spring LS -> sts/addClasspathListener：读类路径并注册回调。
local function on_add_listener(_, params, ctx)
  local callback_id = params and params.callbackCommandId
  if type(callback_id) ~= "string" or callback_id == "" then
    return rpc_error(METHOD.add_listener .. " requires callbackCommandId")
  end

  local spring = ctx and vim.lsp.get_client_by_id(ctx.client_id)
  if not spring or spring:is_stopped() then return rpc_error("Spring Boot LS client is not running") end

  local intellij, err = wait_for_intellij()
  if not intellij then return rpc_error(err) end
  local projects
  projects, err = read_classpath(intellij)
  if not projects then return rpc_error(err or "could not read classpath") end

  local listener = { spring_client_id = spring.id }
  listeners[callback_id] = listener

  -- 必须先返回注册成功，再发回调请求；避免两个 LSP 请求嵌套等待导致死锁。
  vim.schedule(function()
    if not listeners[callback_id] then return end
    push_projects(callback_id, listener, projects)
    if #projects == 0 then retry_empty_classpath(callback_id, 1) end
  end)

  debug("registered listener " .. callback_id .. " for " .. #projects .. " project(s)")
  return vim.empty_dict()
end

local function on_remove_listener(_, params)
  local callback_id = params and params.callbackCommandId
  if type(callback_id) == "string" then listeners[callback_id] = nil end
  debug("removed listener " .. tostring(callback_id))
  return vim.empty_dict()
end

local function on_java_location(_, params)
  local key = params and params.bindingKey
  if is_null(key) then return vim.NIL end

  local client = wait_for_intellij()
  if not client or not has_command(client, METHOD.get_java_location) then return vim.NIL end
  local result = execute_command(client, METHOD.get_java_location, { key })
  return is_null(result) and vim.NIL or result
end

-- 这些方法在所分析的 VS Code -> IntelliJ 桥接中也是空实现。
local handlers = {
  [METHOD.add_listener] = on_add_listener,
  [METHOD.remove_listener] = on_remove_listener,
  [METHOD.java_location] = on_java_location,
  ["sts/javaType"] = function() return vim.NIL end,
  ["sts/javadocHoverLink"] = function() return vim.NIL end,
  ["sts/javadoc"] = function() return vim.NIL end,
  ["sts/javaSearchTypes"] = function() return {} end,
  ["sts/javaSearchPackages"] = function() return {} end,
  ["sts/javaSubTypes"] = function() return {} end,
  ["sts/javaSuperTypes"] = function() return {} end,
  ["sts/javaCodeComplete"] = function() return {} end,
  ["sts/project/gav"] = function() return {} end,
}

local function wrap_handler(handler)
  return function(err, params, ctx)
    if err then return vim.NIL end
    return handler(err, params, ctx)
  end
end

local function patch_client(client)
  if not client or client:is_stopped() or type(client.handlers) ~= "table" then return false end
  -- 客户端级 handler 优先级高于全局 handler；覆盖它才能禁用旧的 JDTLS 转发。
  for method, handler in pairs(handlers) do
    client.handlers[method] = wrap_handler(handler)
  end
  patched_clients[client.id] = true
  debug("patched handlers on " .. client.name .. " (#" .. client.id .. ")")
  return true
end

function M.patch_handlers()
  local spring = spring_client()
  if not spring then log("Spring Boot LS not found", vim.log.levels.WARN); return false end
  if not patch_client(spring) then
    log("could not patch Spring Boot LS handlers", vim.log.levels.ERROR)
    return false
  end
  return true
end

-- 启用 Spring LS 的类路径监听前，先安装请求处理器。
local function enable_listening(spring)
  if not spring or spring:is_stopped() then return false, "Spring Boot LS is not running" end
  if enabled_clients[spring.id] == true or enabled_clients[spring.id] == "pending" then return true end
  if not has_command(spring, METHOD.enable_listening) then
    return false, spring.name .. " does not advertise " .. METHOD.enable_listening
  end

  enabled_clients[spring.id] = "pending"
  local sent = spring:request("workspace/executeCommand", {
    command = METHOD.enable_listening,
    arguments = { true },
  }, function(err)
    if err then
      enabled_clients[spring.id] = nil
      log("enabling classpath listening failed: " .. tostring(err.message or vim.inspect(err)), vim.log.levels.ERROR)
    else
      enabled_clients[spring.id] = true
      debug("classpath listening enabled on " .. spring.name)
    end
  end, 0)

  if not sent then
    enabled_clients[spring.id] = nil
    return false, "could not send " .. METHOD.enable_listening
  end
  return true
end

function M.enable_classpath_listening()
  local spring = spring_client()
  if not spring then log("Spring Boot LS not found", vim.log.levels.WARN); return end
  if not patch_client(spring) then return end
  local ok, err = enable_listening(spring)
  if not ok then log(err, vim.log.levels.WARN) end
end

function M.refresh_classpath()
  local sent = false
  for callback_id, listener in pairs(listeners) do
    local spring = vim.lsp.get_client_by_id(listener.spring_client_id)
    if not spring or spring:is_stopped() then
      listeners[callback_id] = nil
    else
      local intellij, err = wait_for_intellij()
      local projects
      if intellij then projects, err = read_classpath(intellij) end
      if err then
        log(err, vim.log.levels.WARN)
      else
        push_projects(callback_id, listener, projects)
        sent = true
      end
    end
  end
  if not sent then log("no active classpath listeners to refresh") end
end

function M.status()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    names[#names + 1] = client.name .. " (#" .. client.id .. ")"
  end
  local intellij, spring = intellij_client(), spring_client()
  log(table.concat({
    "LSP clients: " .. (#names > 0 and table.concat(names, ", ") or "none"),
    "IntelliJ client: " .. (intellij and (intellij.name .. " (#" .. intellij.id .. ")") or "not found"),
    METHOD.get_classpath .. ": " .. tostring(has_command(intellij, METHOD.get_classpath)),
    METHOD.get_java_location .. ": " .. tostring(has_command(intellij, METHOD.get_java_location)),
    "Spring Boot LS client: " .. (spring and (spring.name .. " (#" .. spring.id .. ")") or "not found"),
    "client-local handlers patched: " .. tostring(spring and patched_clients[spring.id] or false),
    METHOD.enable_listening .. ": " .. tostring(has_command(spring, METHOD.enable_listening)),
    "classpath listening state: " .. tostring(spring and enabled_clients[spring.id] or "not enabled"),
    "classpath listeners: " .. vim.tbl_count(listeners),
  }, "\n"))
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  if not handlers_installed then
    -- 作为默认处理器；下面仍会覆盖 Spring 客户端自身的 handlers。
    for method, handler in pairs(handlers) do
      vim.lsp.handlers[method] = wrap_handler(handler)
    end
    handlers_installed = true
  end

  if not commands_installed then
    vim.api.nvim_create_user_command("SpringBootBridgeStatus", M.status, { desc = "Show Spring/IntelliJ bridge status" })
    vim.api.nvim_create_user_command("SpringBootBridgePatchHandlers", M.patch_handlers, { desc = "Patch Spring LS request handlers" })
    vim.api.nvim_create_user_command("SpringBootBridgeEnableClasspathListening", M.enable_classpath_listening, { desc = "Enable Spring LS classpath listener" })
    vim.api.nvim_create_user_command("SpringBootBridgeRefreshClasspath", M.refresh_classpath, { desc = "Refresh classpath from IntelliJ Server" })
    commands_installed = true
  end

  if not lsp_group then
    lsp_group = vim.api.nvim_create_augroup("SpringBootBridgeLsp", { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = lsp_group,
      callback = function(args)
        local client = args.data and vim.lsp.get_client_by_id(args.data.client_id)
        if client and (has_command(client, METHOD.enable_listening) or client == spring_client()) then
          patch_client(client)
          if config.auto_enable_classpath_listening then
            vim.schedule(function()
              local ok, err = enable_listening(client)
              if not ok then log(err, vim.log.levels.WARN) end
            end)
          end
        end
      end,
    })
  end

  -- 兼容模块在 LSP 已启动之后才加载的情况；重复调用由 enabled_clients 去重。
  if config.auto_enable_classpath_listening then
    vim.schedule(function()
      local spring = spring_client()
      if spring then
        patch_client(spring)
        local ok, err = enable_listening(spring)
        if not ok then log(err, vim.log.levels.WARN) end
      end
    end)
  end

  if config.refresh_on_build_file_write and not build_group then
    build_group = vim.api.nvim_create_augroup("SpringBootBridgeBuild", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = build_group,
      pattern = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts", "gradle/libs.versions.toml" },
      callback = function()
        vim.defer_fn(M.refresh_classpath, config.build_file_refresh_delay)
      end,
    })
  end

  debug("bridge initialized")
  return M
end

return M

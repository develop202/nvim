if vim.g.lemminx_enabled then
  return
end
vim.g.lemminx_enabled = true

local mason_registry = require("mason-registry")
if mason_registry.is_installed("lemminx") then
  local seg = ":"
  if OwnUtil.sys.is_windows() then
    seg = ";"
  end
  local lemminx_jars = {}
  -- 添加maven的jars
  if mason_registry.is_installed("lemminx-maven") then
    local jars_path = vim.fn.expand("$MASON/packages/lemminx-maven") .. "/jars/*.jar"
    for _, bundle in ipairs(vim.split(vim.fn.glob(jars_path), "\n")) do
      table.insert(lemminx_jars, bundle)
    end
  end

  local root_dir = vim.fs.root(vim.fn.getcwd(), OwnUtil.lang.java.root_markers)

  if require("spring_boot.util").has_spring_boot_dependency(root_dir) then
    if mason_registry.is_installed("vscode-spring-boot-tools") then
      local spring_boot_tools = vim.fn.expand("$MASON/packages/vscode-spring-boot-tools") .. "/extension/jars"
      table.insert(lemminx_jars, spring_boot_tools .. "/commons-lsp-extensions.jar")
      table.insert(lemminx_jars, spring_boot_tools .. "/xml-ls-extension.jar")
    end
  end

  -- 添加主jar
  local jar_path = vim.fn.expand("$MASON/packages/lemminx/lemminx.jar")
  table.insert(lemminx_jars, vim.fn.glob(jar_path))
  local cmd = {
    OwnUtil.utils.cmd.java_bin(21),
    "-Xms64M",
    "-Xmx64M",
    "-cp",
    vim.fn.join(lemminx_jars, seg),
    "org.eclipse.lemminx.XMLServerLauncher",
  }
  vim.lsp.config("lemminx", {
    cmd = cmd,
    root_dir = root_dir,
  })
  vim.lsp.enable("lemminx", true)
end

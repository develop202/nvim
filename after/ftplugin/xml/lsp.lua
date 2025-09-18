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

  -- 添加主jar
  local jar_path = vim.fn.expand("$MASON/packages/lemminx/lemminx.jar")
  table.insert(lemminx_jars, vim.fn.glob(jar_path))
  local cmd = {
    OwnUtil.utils.cmd.java_bin(),
    "-Xms64m",
    "-Xmx64m",
    "-cp",
    vim.fn.join(lemminx_jars, seg),
    "org.eclipse.lemminx.XMLServerLauncher",
  }
  vim.lsp.config("lemminx", {
    cmd = cmd,
  })
  vim.lsp.enable("lemminx", true)
end

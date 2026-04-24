---@class util.lsp
local M = {}

M.java = {}

M.java.root_markers = {
  ".git", -- IDE
  ".idea",
  ".project",

  "mvnw", -- Maven
  "pom.xml",

  "gradlew", -- Gradle
  "settings.gradle",
  "settings.gradle.kts",

  "build.xml", -- Ant
}

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

return M

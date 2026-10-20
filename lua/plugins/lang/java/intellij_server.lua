return {
  {
    "AlexandrosAlexiou/intellij-server.nvim",
    -- enabled = vim.g.intellij_java,
    ft = vim.g.intellij == true and { "java", "kotlin" } or "abcdef",
    dependencies = {
      "mfussenegger/nvim-dap",
      { "stevearc/oil.nvim", opts = {} },
    }, -- optional
    opts = function()
      local server_path = nil
      local server_java_home = nil
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed("intellij-server") then
        local install_path = vim.fn.expand("$MASON/packages/intellij-server/intellij-server-*")

        if OwnUtil.sys.is_termux() then
          OwnUtil.utils.lsp.intellij_termux_adapted(install_path)

          vim.fn.setenv("LD_PRELOAD", "")
        end
        server_path = install_path .. "/bin/intellij-server"

        server_java_home = install_path .. "/jbr"
      end
      return {
        filetypes = { "java", "kotlin" },
        server_path = server_path,

        default_sdk = vim.env["$JAVA_17_HOME"] or nil,
        java_home = server_java_home,
        connection = { mode = "socket" },
      }
    end,
  },
  {
    "JetBrains/intellij-lsp.nvim",
    ft = vim.g.intellij == "official" and { "java", "kotlin" } or "abcdef",
    dependencies = { "mfussenegger/nvim-dap" }, -- optional: run and debug
    opts = function()
      local server_path = nil
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed("intellij-server") then
        local install_path = vim.fn.expand("$MASON/packages/intellij-server/intellij-server-*")

        if OwnUtil.sys.is_termux() then
          OwnUtil.utils.lsp.intellij_termux_adapted(install_path)

          vim.fn.setenv("LD_PRELOAD", "")
        end
        server_path = install_path .. "/bin/intellij-server"
      end
      return {
        server_download = false,

        autotrigger = false, -- open the completion menu on "."
        word_triggers = false,

        accept_eula = true, -- read EULA.txt in the downloaded bundle first

        rename_files = true,

        server_path = server_path, -- use your own bundle instead of downloading
        default_sdk = vim.env["$JAVA_17_HOME"] or nil, -- JDK for projects that do not configure their own
      }
    end,
  },
}

return {
  {
    "AlexandrosAlexiou/intellij-server.nvim",
    -- enabled = vim.g.intellij_java,
    ft = vim.g.intellij and { "java", "kotlin" } or "abcdef",
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
}

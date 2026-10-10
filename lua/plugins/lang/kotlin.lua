return {
  {
    "AlexandrosAlexiou/kotlin.nvim",
    ft = vim.g.intellij and { "abcdef" } or { "kotlin" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "stevearc/oil.nvim",
      "folke/trouble.nvim",
      -- nvim-dap is NOT a kotlin.nvim dependency. Install and configure it
      -- separately (signs, keymaps, optionally nvim-dap-ui). kotlin.nvim only
      -- registers a `kotlin` adapter and the `:KotlinDebug` command on top.
      -- See the "Debugging Support" section below for details.
    },
    opts = function()
      local mason_registry = require("mason-registry")
      if mason_registry.is_installed("kotlin-lsp") then
        local install_path = vim.fn.expand("$MASON/packages/kotlin-lsp/kotlin-server-*")

        if OwnUtil.sys.is_termux() then
          OwnUtil.utils.lsp.intellij_termux_adapted(install_path)

          vim.fn.setenv("LD_PRELOAD", "")
        end
      end

      return {
        jdk_for_symbol_resolution = vim.env["$JAVA_17_HOME"] or nil,
        inlay_hints = {
          enabled = true,
        },
      }
    end,
  },
}

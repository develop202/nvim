return {
  {
    "folke/persistence.nvim",
    opts = function()
      if not vim.g.persistence_loaded then
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          106,
          "local function handle_selected(opts)"
        )
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          125,
          "    prompt = opts.prompt,"
        )

        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          131,
          "      opts.handler(item)"
        )

        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          132,
          ""
        )
        -- 选择
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          136,
          'function M.select() handle_selected({ prompt = "Select a session: ", handler = function(item) local ok, _ = pcall(function() vim.fn.chdir(item.dir) M.load() end) if not ok then os.remove(item.session) print("Deleted not exist session " .. item.dir .. ".") end end, }) end'
        )
        -- 删除
        OwnUtil.utils.termux_change_file_line(
          vim.fn.stdpath("data") .. "/lazy/persistence.nvim/lua/persistence/init.lua",
          145,
          'function M.delete() handle_selected({ prompt = "Delete a session: ", handler = function(item) os.remove(item.session) print("Deleted " .. item.session) end, }) end'
        )
        vim.g.persistence_loaded = 1
      end
    end,
    keys = {
      -- 删除选择会话
      {
        "<leader>qD",
        function()
          require("persistence").delete()
        end,
        desc = "Delete Select Session",
      },
    },
  },
}

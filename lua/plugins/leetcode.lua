local is_enabled = false

if vim.env.TERM == "xterm-kitty" then
  -- Example for configuring Neovim to load user-installed installed Lua rocks:
  package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
  package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

  is_enabled = true
end

return {
  "kawre/leetcode.nvim",
  event = "VeryLazy",
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim", -- telescope 所需
    "MunifTanjim/nui.nvim",

    -- 可选
    "nvim-treesitter/nvim-treesitter",
    "rcarriga/nvim-notify",
    "nvim-tree/nvim-web-devicons",
    {
      "3rd/image.nvim",
      enabled = is_enabled,
      config = function()
        require("image").setup()
      end,
    },
  },
  opts = {
    -- 配置放在这里
    cn = {
      enabled = true,
    },
    lang = "java",
    storage = {
      home = "~/.leetcode",
      cache = "~/.leetcode/cache",
    },
    image_support = is_enabled,
  },
}

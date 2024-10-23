local is_enabled = false
local HOME = os.getenv("HOME")

if vim.env.TERM == "xterm-kitty" then
  -- Example for configuring Neovim to load user-installed installed Lua rocks:
  package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
  package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"

  is_enabled = true
end

return {
  "kawre/leetcode.nvim",
  cmd = { "Leet" },
  build = ":TSUpdate html",
  dependencies = {
    {
      "nvim-telescope/telescope.nvim",
      event = "LazyFile",
    },
    "MunifTanjim/nui.nvim",

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
      home = HOME .. "/.leetcode",
      cache = HOME .. "/.leetcode/cache",
    },
    image_support = is_enabled,
  },
}

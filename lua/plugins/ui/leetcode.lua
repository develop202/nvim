local is_enabled = false
local HOME = vim.env["HOME"]

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
      opts = {
        defaults = {
          -- 将文件名提到开头，路径颜色变暗
          path_display = {
            filename_first = {
              reverse_directories = false,
            },
          },
          -- 显示右侧预览，不过在手机上很窄，不美观
          -- layout_strategy = "horizontal",
          -- layout_config = {
          --   width = 0.8,
          --   preview_cutoff = 1,
          -- },
          layout_strategy = "vertical",
          layout_config = {
            vertical = {
              preview_cutoff = 20,
              preview_height = 0.6,
              -- mirror = true,
            },
            -- height = { padding = 0 },
            -- width = { padding = 0 },
          },
        },
        -- 预览和搜索结果上下分布，看着有些怪，但是搜索结果显示完整一些
        -- pickers = {
        --   find_files = {
        --     theme = "dropdown",
        --   },
        -- },
      },
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

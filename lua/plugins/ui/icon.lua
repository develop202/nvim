local default = {}
local directory = {}
local extension = {}
local file = {
  [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
  ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },

  -- ui
  [".node-version"] = { glyph = "󰎙" },
  ["package.json"] = { glyph = "󰎙" },

  -- maven
  ["pom.xml"] = { glyph = "", hl = "MiniIconsRed" },

  -- spring
  ["application.properties"] = { glyph = "", hl = "SpringBootIcon" },
  ["application.yml"] = { glyph = "", hl = "SpringBootIcon" },
  ["bootstrap.properties"] = { glyph = "", hl = "SpringBootIcon" },
  ["bootstrap.yml"] = { glyph = "", hl = "SpringBootIcon" },
  ["application.yaml"] = { glyph = "", hl = "SpringBootIcon" },
  ["bootstrap.yaml"] = { glyph = "", hl = "SpringBootIcon" },
}

local filetype = {
  dotenv = { glyph = "", hl = "MiniIconsYellow" },

  -- java
  jproperties = { glyph = "", hl = "PropertiesIcon" },
}
local lsp = {}
local os = {}

return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {
      default = default,
      directory = directory,
      extension = extension,
      file = file,
      filetype = filetype,
      lsp = lsp,
      os = os,
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = {
        keys = {
          BS = "󰁮 ",
          F10 = "󱊴 ",
          F11 = "󱊵 ",
          F12 = "󱊶 ",
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}

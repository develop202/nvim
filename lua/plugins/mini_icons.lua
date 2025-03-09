local default = {}
local directory = {}
local extension = {}
local file = {
  -- ui
  [".keep"] = { glyph = "󰊢 ", hl = "MiniIconsGrey" },
  ["devcontainer.json"] = { glyph = " ", hl = "MiniIconsAzure" },

  -- Chezmoi
  [".chezmoiignore"] = { glyph = " ", hl = "MiniIconsGrey" },
  [".chezmoiremove"] = { glyph = " ", hl = "MiniIconsGrey" },
  [".chezmoiroot"] = { glyph = " ", hl = "MiniIconsGrey" },
  [".chezmoiversion"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["bash.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["json.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["ps1.tmpl"] = { glyph = "󰨊 ", hl = "MiniIconsGrey" },
  ["sh.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["toml.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["yaml.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },
  ["zsh.tmpl"] = { glyph = " ", hl = "MiniIconsGrey" },

  -- Typescript
  [".eslintrc.js"] = { glyph = "󰱺 ", hl = "MiniIconsYellow" },
  [".node-version"] = { glyph = " ", hl = "MiniIconsGreen" },
  [".prettierrc"] = { glyph = " ", hl = "MiniIconsPurple" },
  [".yarnrc.yml"] = { glyph = " ", hl = "MiniIconsBlue" },
  ["eslint.config.js"] = { glyph = "󰱺 ", hl = "MiniIconsYellow" },
  ["package.json"] = { glyph = " ", hl = "MiniIconsGreen" },
  ["tsconfig.json"] = { glyph = " ", hl = "MiniIconsAzure" },
  ["tsconfig.build.json"] = { glyph = " ", hl = "MiniIconsAzure" },
  ["yarn.lock"] = { glyph = " ", hl = "MiniIconsBlue" },

  -- go
  [".go-version"] = { glyph = " ", hl = "MiniIconsBlue" },

  -- maven
  ["pom.xml"] = { glyph = " ", hl = "MiniIconsRed" },

  -- spring
  ["application.properties"] = { glyph = " ", hl = "SpringBootIcon" },
  ["application.yml"] = { glyph = " ", hl = "SpringBootIcon" },
  ["bootstrap.properties"] = { glyph = " ", hl = "SpringBootIcon" },
  ["bootstrap.yml"] = { glyph = " ", hl = "SpringBootIcon" },
}

local filetype = {
  -- ui
  dotenv = { glyph = " ", hl = "MiniIconsYellow" },

  -- go
  gotmpl = { glyph = "󰟓 ", hl = "MiniIconsGrey" },
}
local lsp = {}
local os = {}

default = vim.tbl_deep_extend("force", default, OwnUtil.mini_icons.default)

directory = vim.tbl_deep_extend("force", directory, OwnUtil.mini_icons.directory)

extension = vim.tbl_deep_extend("force", extension, OwnUtil.mini_icons.extension)

file = vim.tbl_deep_extend("force", file, OwnUtil.mini_icons.file)

filetype = vim.tbl_deep_extend("force", filetype, OwnUtil.mini_icons.filetype)

lsp = vim.tbl_deep_extend("force", lsp, OwnUtil.mini_icons.lsp)

os = vim.tbl_deep_extend("force", os, OwnUtil.mini_icons.os)
return {
  {
    "echasnovski/mini.icons",
    opts = {
      default = default,
      directory = directory,
      extension = extension,
      file = file,
      filetype = filetype,
      lsp = lsp,
      os = os,
    },
  },
}

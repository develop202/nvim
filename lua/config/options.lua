-- Add any additional options here
local option = vim.opt
-- local buffer = vim.b
local global = vim.g

global.intellij = "official"

-- 状态栏
if OwnUtil.sys.is_termux() then
  global.mini_statusline = true
else
  global.lualine = true
end

require("vim._core.ui2").enable({
  enable = false,
})

vim.diagnostic.config(vim.deepcopy({
  -- insert模式下显示诊断信息
  -- 更新太频繁
  -- update_in_insert = true,
  virtual_text = false,
  -- 悬浮窗显示来源
  float = {
    border = "rounded",
    source = "always",
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = OwnUtil.icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = OwnUtil.icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = OwnUtil.icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = OwnUtil.icons.diagnostics.Info,
    },
  },
}))

option.cmdheight = 0

option.tabstop = 2
option.shiftwidth = 2
option.swapfile = false
option.hlsearch = false

-- 内置拼写检查
-- option.spell = true
option.spelllang = "en_us,cjk"
option.spelloptions = "camel"

-- 自动折行
option.wrap = true
option.linebreak = true -- 在单词边界处折行（更美观）
option.breakindent = true -- 折行后保持缩进

-- 关闭透明显示
-- 关掉可以让cmp补全列表图标正常显示
option.pumblend = 0

-- wsl粘贴板共享到宿主机
if vim.fn.has("wsl") == 1 then
  global.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --crlf",
      ["*"] = "win32yank.exe -o --crlf",
    },
    cache_enable = 0,
  }
end

option.mousemoveevent = true
-- global.groovy_format_indent_first = true

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- global.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- Hide deprecation warnings
-- global.deprecation_warnings = false

option.autowrite = true -- Enable auto write
option.completeopt = "menu,menuone,noselect"
option.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
option.confirm = true -- Confirm to save changes before exiting modified buffer
option.cursorline = true -- Enable highlighting of the current line
option.expandtab = true -- Use spaces instead of tabs
option.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
option.foldlevel = 99
option.foldmethod = "indent"
option.foldtext = ""

option.grepformat = "%f:%l:%c:%m"
option.grepprg = "rg --vimgrep"
option.ignorecase = true -- Ignore case
option.inccommand = "nosplit" -- preview incremental substitute
option.jumpoptions = "view"
option.laststatus = 3 -- global statusline
option.list = true -- Show some invisible characters (tabs...
option.mouse = "a" -- Enable mouse mode
option.number = true -- Print line number
option.pumblend = 10 -- Popup blend
option.pumheight = 10 -- Maximum number of entries in a popup
option.relativenumber = true -- Relative line numbers
option.ruler = false -- Disable the default ruler
option.scrolloff = 4 -- Lines of context
option.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
option.shiftround = true -- Round indent
option.shiftwidth = 2 -- Size of an indent
option.shortmess:append({ W = true, I = true, c = true, C = true })
option.showmode = false -- Dont show mode since we have a statusline
option.sidescrolloff = 8 -- Columns of context
option.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
option.smartcase = true -- Don't ignore case with capitals
option.smartindent = true -- Insert indents automatically
option.smoothscroll = true
-- option.spelllang = { "en" }
option.splitbelow = true -- Put new windows below current
option.splitkeep = "screen"
option.splitright = true -- Put new windows right of current
option.termguicolors = true -- True color support
option.timeoutlen = global.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
option.undofile = true
option.undolevels = 10000
option.updatetime = 200 -- Save swap file and trigger CursorHold
option.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
option.wildmode = "longest:full,full" -- Command-line completion mode
option.winminwidth = 5 -- Minimum window width

local window_width = 25
if os.getenv("HOME") == "/data/data/com.termux/files/home" then
  window_width = 60
end
return {
  "hedyhli/outline.nvim",
  cmd = "Outline",
  opts = {
    outline_window = {
      width = window_width,
    },
    symbol_folding = {
      markers = { " ", " " },
    },
    providers = {
      lsp = {
        -- 忽略lsp
        blacklist_clients = { "spring-boot", "ruff" },
      },
    },
    symbols = {
      icons = {
        File = { icon = " ", hl = "Identifier" },
        Module = { icon = " ", hl = "Include" },
        Namespace = { icon = " ", hl = "Include" },
        Package = { icon = "󰏗 ", hl = "Include" },
        Class = { icon = " ", hl = "Type" },
        Method = { icon = " ", hl = "Function" },
        Property = { icon = " ", hl = "Identifier" },
        Field = { icon = " ", hl = "Identifier" },
        Constructor = { icon = " ", hl = "Special" },
        Enum = { icon = " ", hl = "Type" },
        Interface = { icon = " ", hl = "Type" },
        Function = { icon = " ", hl = "Function" },
        Variable = { icon = " ", hl = "Constant" },
        Constant = { icon = " ", hl = "Constant" },
        String = { icon = " ", hl = "String" },
        Number = { icon = "󰎠 ", hl = "Number" },
        Boolean = { icon = " ", hl = "Boolean" },
        Array = { icon = " ", hl = "Constant" },
        Object = { icon = " ", hl = "Type" },
        Key = { icon = "󰌋 ", hl = "Type" },
        Null = { icon = " ", hl = "Type" },
        EnumMember = { icon = " ", hl = "Identifier" },
        Struct = { icon = " ", hl = "Structure" },
        Event = { icon = " ", hl = "Type" },
        Operator = { icon = " ", hl = "Identifier" },
        TypeParameter = { icon = " ", hl = "Identifier" },
        Component = { icon = "󰡀 ", hl = "Function" },
        Fragment = { icon = "󰅴 ", hl = "Constant" },
        -- ccls
        TypeAlias = { icon = " ", hl = "Type" },
        Parameter = { icon = " ", hl = "Identifier" },
        StaticMethod = { icon = " ", hl = "Function" },
        Macro = { icon = " ", hl = "Function" },
      },
    },
    keymaps = {
      goto_location = "o",
      fold_toggle = "<CR>",
      peek_location = "p",
    },
  },
}

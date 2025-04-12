return {
  "luozhiya/fittencode.nvim",
  event = "LazyFile",
  opts = {
    inline_completion = {
      -- 关闭行内补全
      enable = false,
    },
  },
  keys = {
    {
      "<leader>fae",
      "<cmd>Fitten enable_completions<cr>",
      desc = "开启Fitten AI提示",
    },
    {
      "<leader>fad",
      "<cmd>Fitten disable_completions<cr>",
      desc = "关闭Fitten AI提示",
    },
    {
      -- 用于句子翻译
      "<leader>tc",
      "<cmd>Fitten translate_text_into_chinese<cr>",
      mode = { "n", "v", "x" },
      desc = "AI英译汉",
    },
    {
      "<leader>fat",
      "<cmd>Fitten toggle_chat<cr>",
      desc = "开启/关闭Fitten AI对话窗口",
    },
    {
      "<leader>fao",
      "<cmd>Fitten start_chat<cr>",
      desc = "开始AI对话",
    },
  },
}

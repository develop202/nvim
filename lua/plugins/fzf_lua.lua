return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      -- 去除图标与文本之间的空格
      nbsp = "\x12",
      -- 让图标占两格
      file_icon_padding = " ",
      -- 文件名提到目录前面
      defaults = {
        formatter = "path.filename_first",
      },
      -- ui布局
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, { prompt = " " }, {
          winopts = {
            width = 0.8,
          },
        })
      end,
    },
  },
}

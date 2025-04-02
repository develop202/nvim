local function symbols_filter(entry, ctx)
  if ctx.symbols_filter == nil then
    ctx.symbols_filter = LazyVim.config.get_kind_filter(ctx.bufnr) or false
  end
  if ctx.symbols_filter == false then
    return true
  end
  return vim.tbl_contains(ctx.symbols_filter, entry.kind)
end

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
    keys = {
      {
        "<leader>ss",
        function()
          require("fzf-lua").lsp_document_symbols({
            regex_filter = symbols_filter,
            -- 解决lsp_document_symbols列表不显示的问题
            fzf_opts = { ["--with-nth"] = "1.." },
          })
        end,
        desc = "Goto Symbol",
      },
    },
  },
}

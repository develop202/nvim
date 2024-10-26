return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      defaults = {
        formatter = "path.filename_first",
      },
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

return {
  {
    "kevinhwang91/nvim-ufo",
    event = "LazyFile",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    opts = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      -- global handler
      return {
        -- 自动折叠导入内容
        -- close_fold_kinds_for_ft = {
        --   default = { "imports" },
        -- },
        fold_virt_text_handler = handler,

        preview = {},
        open_fold_hl_timeout = 150,
        UfoConfig = {},
        enable_get_fold_virt_text = false,
        provider_selector = function(bufnr, filetype, buftype)
          if filetype == "vue" or filetype == "html" then
            -- 使用treesitter作为折叠依据
            return { "treesitter", "indent" }
          end
          return { "lsp", "indent" }
        end,
      }
    end,
  },
}

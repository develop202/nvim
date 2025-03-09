-- 强制请求volar语言服务器
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("VueLSPAttach", { clear = true }),
  callback = function(args)
    local clients = vim.lsp.get_clients()
    local bufnr = args.buf

    -- 仅在 Vue 文件类型中触发
    if vim.bo[bufnr].filetype == "vue" and clients[1].name == "vtsls" and #clients >= 2 then
      vim.notify("vtsls优先启动")
      vim.notify("正在重启vtsls…")
      -- 重新启动
      vim.cmd("LspRestart vtsls")
      vim.notify("vtsls重启成功")
      -- 延迟刷新文件
      -- 直接刷新会导致lsp和页面刷新报错
      vim.defer_fn(function()
        -- 重新加载文件
        -- 刷新dropbar.nvim面包屑插件
        vim.cmd("e")
        vim.notify("文件刷新成功")
      end, 100)
    end
  end,
})

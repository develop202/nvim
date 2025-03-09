local window_width = 25
if OwnUtil.sys.is_termux() then
  window_width = 60
end
return {
  "hedyhli/outline.nvim",
  cmd = "Outline",
  opts = function(_, opts)
    opts.outline_window = {
      width = window_width,
    }
    opts.providers = {
      lsp = {
        -- 忽略lsp
        blacklist_clients = { "spring-boot", "ruff" },
      },
    }
    local icons = require("outline.config").defaults.symbols.icons
    for key, _ in pairs(icons) do
      -- 使用自己的图标
      icons[key].icon = OwnUtil.icons.kinds[key] or icons[key].icon
    end

    opts.symbols = icons

    opts.keymaps = {
      goto_location = "o",
      fold_toggle = "<CR>",
      peek_location = "p",
    }
  end,
  -- 使用init会导致大纲字段颜色被修改,所以使用config
  config = function(_, opts)
    local sidebar = require("outline.sidebar")
    local cfg = require("outline.config")
    local providers = require("outline.providers.init")

    -- 获取volar客户端
    local get_volar_client = function()
      local clients = vim.lsp.get_clients()
      for _, cli in ipairs(clients) do
        if cli.name == "volar" then
          return { client = cli }
        end
      end
    end
    -- 刷新大纲
    sidebar.__refresh = function(self)
      local buf = vim.api.nvim_get_current_buf()
      local focused_outline = self.view.buf == buf
      if focused_outline or not self.view:is_open() then
        return
      end
      local ft = vim.api.nvim_buf_get_option(buf, "ft")
      local listed = vim.api.nvim_buf_get_option(buf, "buflisted")
      if ft == "OutlineHelp" or not listed then
        return
      end
      self.provider, self.provider_info = providers.find_provider()
      if self.provider_info ~= nil and self.provider_info.client.name == "vtsls" and vim.o.filetype == "vue" then
        self.provider_info = get_volar_client()
      end
      if self.provider then
        self.provider.request_symbols(function(res)
          self:refresh_handler(res)
        end, nil, self.provider_info)
        return
      end
      -- No provider
      self:refresh_setup()
      self:no_providers_ui()
    end
    -- 打开大纲
    sidebar.open = function(self, opt)
      if not opt then
        opt = { focus_outline = true }
      end

      if not self.view:is_open() then
        self.preview.s = self
        self.provider, self.provider_info = providers.find_provider()
        if self.provider_info ~= nil and self.provider_info.client.name == "vtsls" and vim.o.filetype == "vue" then
          self.provider_info = get_volar_client()
        end
        if self.provider then
          self.provider.request_symbols(function(...)
            self:initial_handler(...)
          end, opt, self.provider_info)
          return
        else
          -- No provider
          self:initial_setup(opt)
          self:no_providers_ui()
        end
        if not cfg.o.outline_window.focus_on_open or not opt.focus_outline then
          vim.fn.win_gotoid(self.code.win)
        end
      else
        if cfg.o.outline_window.focus_on_open and opt.focus_outline then
          self:focus()
        end
      end
    end
    require("outline").setup(opts)
  end,
}

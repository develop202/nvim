return {
  {
    -- 面包屑导航
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
    opts = {
      icons = {
        kinds = {
          symbols = OwnUtil.icons.kinds,
        },
      },
    },
    config = function(_, opts)
      local configs = require("dropbar.configs")
      local bar = require("dropbar.bar")
      local groupid = vim.api.nvim_create_augroup("DropBarLsp", {})
      local initialized = false

      ---@type table<integer, lsp_document_symbol_t[]>
      local lsp_buf_symbols = {}
      setmetatable(lsp_buf_symbols, {
        __index = function(_, k)
          lsp_buf_symbols[k] = {}
          return lsp_buf_symbols[k]
        end,
      })
      local symbol_kind_names = setmetatable({
        [1] = "File",
        [2] = "Module",
        [3] = "Namespace",
        [4] = "Package",
        [5] = "Class",
        [6] = "Method",
        [7] = "Property",
        [8] = "Field",
        [9] = "Constructor",
        [10] = "Enum",
        [11] = "Interface",
        [12] = "Function",
        [13] = "Variable",
        [14] = "Constant",
        [15] = "String",
        [16] = "Number",
        [17] = "Boolean",
        [18] = "Array",
        [19] = "Object",
        [20] = "Keyword",
        [21] = "Null",
        [22] = "EnumMember",
        [23] = "Struct",
        [24] = "Event",
        [25] = "Operator",
        [26] = "TypeParameter",
      }, {
        __index = function()
          return ""
        end,
      })

      local function convert_document_symbol(document_symbol, buf, win, siblings, idx)
        local kind = symbol_kind_names[document_symbol.kind]
        return bar.dropbar_symbol_t:new(setmetatable({
          buf = buf,
          win = win,
          name = document_symbol.name,
          icon = configs.opts.icons.kinds.symbols[kind],
          name_hl = "DropBarKind" .. kind,
          icon_hl = "DropBarIconKind" .. kind,
          range = document_symbol.range,
          sibling_idx = idx,
        }, {
          __index = function(self, k)
            if k == "children" then
              if not document_symbol.children then
                return nil
              end
              self.children = vim.tbl_map(function(child)
                return convert_document_symbol(child, buf, win)
              end, document_symbol.children)
              return self.children
            elseif k == "siblings" then
              if not siblings then
                return nil
              end
              self.siblings = vim.tbl_map(function(sibling)
                return convert_document_symbol(sibling, buf, win, siblings)
              end, siblings)
              return self.siblings
            end
          end,
        }))
      end

      local function cursor_in_range(cursor, range)
        local cursor0 = { cursor[1] - 1, cursor[2] }
        return (
          cursor0[1] > range.start.line
          or (cursor0[1] == range.start.line and cursor0[2] >= range.start.character)
        )
          and (
            cursor0[1] < range["end"].line
            or (cursor0[1] == range["end"].line and cursor0[2] <= range["end"].character)
          )
        -- stylua: ignore end
      end
      local function convert_document_symbol_list(lsp_symbols, dropbar_symbols, buf, win, cursor)
        -- Parse in reverse order so that the symbol with the largest start position
        -- is preferred
        for idx, symbol in vim.iter(lsp_symbols):enumerate():rev() do
          if cursor_in_range(cursor, symbol.range) then
            table.insert(dropbar_symbols, convert_document_symbol(symbol, buf, win, lsp_symbols, idx))
            if symbol.children then
              convert_document_symbol_list(symbol.children, dropbar_symbols, buf, win, cursor)
            end
            return
          end
        end
      end

      local function detach(buf)
        if vim.b[buf].dropbar_lsp_attached then
          vim.api.nvim_del_autocmd(vim.b[buf].dropbar_lsp_attached)
          vim.b[buf].dropbar_lsp_attached = nil
          lsp_buf_symbols[buf] = nil
          for _, dropbar in pairs(_G.dropbar.bars[buf]) do
            dropbar:update()
          end
        end
      end

      local function range_contains(range1, range2)
        return (
          range2.start.line > range1.start.line
          or (range2.start.line == range1.start.line and range2.start.character > range1.start.character)
        )
          and (range2.start.line < range1["end"].line or (range2.start.line == range1["end"].line and range2.start.character < range1["end"].character))
          and (range2["end"].line > range1.start.line or (range2["end"].line == range1.start.line and range2["end"].character > range1.start.character))
          and (
            range2["end"].line < range1["end"].line
            or (range2["end"].line == range1["end"].line and range2["end"].character < range1["end"].character)
          )
        -- stylua: ignore end
      end

      local function symbol_type(symbols)
        if symbols[1] and symbols[1].location then
          return "SymbolInformation"
        elseif symbols[1] and symbols[1].range then
          return "DocumentSymbol"
        end
      end

      local function unify(symbols)
        if symbol_type(symbols) == "DocumentSymbol" or vim.tbl_isempty(symbols) then
          return symbols
        end
        -- Convert SymbolInformation[] to DocumentSymbol[]
        for _, sym in ipairs(symbols) do
          sym.range = sym.location.range
        end
        local document_symbols = { symbols[1] }
        -- According to the result get from pylsp, the SymbolInformation list is
        -- ordered in increasing order by the start position of the range, so a
        -- symbol can only be a child or a sibling of the previous symbol in the
        -- same list
        for list_idx, sym in vim.iter(symbols):enumerate():skip(1) do
          local prev = symbols[list_idx - 1] --[[@as lsp_symbol_information_tree_t]]
          -- If the symbol is a child of the previous symbol
          if range_contains(prev.location.range, sym.location.range) then
            sym.parent = prev
          else -- Else the symbol is a sibling of the previous symbol
            sym.parent = prev.parent
          end
          if sym.parent then
            sym.parent.children = sym.parent.children or {}
            table.insert(sym.parent.children, sym)
          else
            table.insert(document_symbols, sym)
          end
        end
        return document_symbols
      end

      local function update_symbols(buf, ttl)
        ttl = ttl or configs.opts.sources.lsp.request.ttl_init
        if ttl <= 0 or not vim.api.nvim_buf_is_valid(buf) then
          lsp_buf_symbols[buf] = nil
          return
        end

        local function _defer_update_symbols()
          vim.defer_fn(function()
            update_symbols(buf, ttl - 1)
          end, configs.opts.sources.lsp.request.interval)
        end

        local clients = vim.tbl_filter(
          function(client)
            return client.supports_method("textDocument/documentSymbol")
          end,
          vim.lsp.get_clients({
            bufnr = buf,
          })
        )
        local client = clients[1]
        if not client then
          _defer_update_symbols()
          return
        end

        -- vue文件下，强制请求volar
        if client.name == "vtsls" and vim.o.filetype == "vue" and clients[2] ~= nil then
          client = clients[2]
        end

        client.request(
          "textDocument/documentSymbol",
          { textDocument = vim.lsp.util.make_text_document_params(buf) },
          function(err, symbols, _)
            if err or not symbols or vim.tbl_isempty(symbols) then
              _defer_update_symbols()
              return
            end
            lsp_buf_symbols[buf] = unify(symbols)
          end,
          buf
        )
      end
      local function attach(buf)
        if vim.b[buf].dropbar_lsp_attached then
          return
        end

        update_symbols(buf)
        vim.b[buf].dropbar_lsp_attached = vim.api.nvim_create_autocmd(configs.opts.bar.update_events.buf, {
          group = groupid,
          buffer = buf,
          callback = function(info)
            update_symbols(info.buf)
          end,
        })
      end
      local function init()
        if initialized then
          return
        end
        initialized = true
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local clients = vim.tbl_filter(function(client)
            return client.supports_method("textDocument/documentSymbol")
          end, vim.lsp.get_clients({ bufnr = buf }))
          if not vim.tbl_isempty(clients) then
            attach(buf)
          end
        end
        vim.api.nvim_create_autocmd({ "LspAttach" }, {
          desc = "Attach LSP symbol getter to buffer when an LS that supports documentSymbol attaches.",
          group = groupid,
          callback = function(info)
            local client = vim.lsp.get_client_by_id(info.data and info.data.client_id)
            if client and client.supports_method("textDocument/documentSymbol") then
              attach(info.buf)
            end
          end,
        })
        vim.api.nvim_create_autocmd({ "LspDetach" }, {
          desc = "Detach LSP symbol getter from buffer when no LS supporting documentSymbol is attached.",
          group = groupid,
          callback = function(info)
            if
              vim.tbl_isempty(vim.tbl_filter(function(client)
                return client.supports_method("textDocument/documentSymbol") and client.id ~= info.data.client_id
              end, vim.lsp.get_clients({ bufnr = info.buf })))
            then
              detach(info.buf)
            end
          end,
        })
        vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeOut" }, {
          desc = "Detach LSP symbol getter from buffer on buffer delete/unload/wipeout.",
          group = groupid,
          callback = function(info)
            detach(info.buf)
          end,
        })
      end
      require("dropbar.sources.lsp").get_symbols = function(buf, win, cursor)
        if not initialized then
          init()
        end
        local result = {}
        convert_document_symbol_list(lsp_buf_symbols[buf], result, buf, win, cursor)
        return result
      end
      require("dropbar").setup(opts)
    end,
  },
}

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
      icons[key].icon = OwnUtil.icons.kinds[key] or icons[key].icon .. " "
    end

    opts.keymaps = {
      goto_location = "o",
      fold_toggle = "<CR>",
      peek_location = "p",
    }

    local cfg = require("outline.config")
    local symbols = require("outline.symbols")
    local strlen = vim.fn.strlen
    local utils = require("outline.utils.init")
    local folding = require("outline.folding")
    local parser = require("outline.parser")

    -- 去除图标和文字间的多余空格
    require("outline.sidebar").build_outline = function(self, find_node)
      ---@type integer 0-indexed
      local hovered_line = vim.api.nvim_win_get_cursor(self.code.win)[1] - 1
      ---@type outline.FlatSymbol Deepest visible matching node to set cursor
      local put_cursor
      self.flats = {}
      local line_count = 0
      local lines = {} ---@type string[]
      local details = {} ---@type string[]
      local linenos = {} ---@type string[]
      local hl = {} ---@type outline.HL[]

      local lineno_offset = 0
      local lineno_prefix = ""
      local lineno_max_width = #tostring(vim.api.nvim_buf_line_count(self.code.buf) - 1)
      if cfg.o.outline_items.show_symbol_lineno then
        lineno_offset = math.max(2, lineno_max_width) + 1
        lineno_prefix = string.rep(" ", lineno_offset)
      end

      -- Closures for convenience
      local function save_guide_hl(from, to)
        table.insert(hl, {
          line = line_count,
          name = "OutlineGuides",
          from = from,
          to = to,
        })
      end
      local function save_fold_hl(from, to)
        table.insert(hl, {
          line = line_count,
          name = "OutlineFoldMarker",
          from = from,
          to = to,
        })
      end

      local guide_markers = cfg.o.guides.markers
      local fold_markers = cfg.o.symbol_folding.markers

      for node in parser.preorder_iter(self.items) do
        line_count = line_count + 1
        node.line_in_outline = line_count
        table.insert(self.flats, node)

        node.hovered = false
        if node.line == hovered_line or (hovered_line >= node.range_start and hovered_line <= node.range_end) then
          -- Not setting for children, but it works because when unfold is called
          -- this function is called again anyway.
          node.hovered = true
          table.insert(self.hovered, node)
          if not find_node then
            put_cursor = node
          end
        end
        if find_node and find_node == node then
          ---@diagnostic disable-next-line: cast-local-type
          put_cursor = find_node
        end

        table.insert(details, node.detail or "")
        local lineno = tostring(node.range_start + 1)
        local leftpad = string.rep(" ", lineno_max_width - #lineno)
        table.insert(linenos, leftpad .. lineno)

        -- Make the guides for the line prefix
        local pref = utils.str_to_table(string.rep(" ", node.depth))
        local fold_marker_width = 0

        if folding.is_foldable(node) then
          -- Add fold marker
          local marker = fold_markers[2]
          if folding.is_folded(node) then
            marker = fold_markers[1]
          end
          pref[#pref] = marker
          fold_marker_width = strlen(marker)
        else
          -- Rightmost guide for the direct parent, only added if fold marker is
          -- not added
          if node.depth > 1 then
            local marker = guide_markers.middle
            if node.isLast then
              marker = guide_markers.bottom
            end
            pref[#pref] = marker
          end
        end

        local iternode = node
        for i = node.depth - 1, 2, -1 do
          iternode = iternode.parent_node
          if not iternode.isLast then
            pref[i] = guide_markers.vertical
          end
        end

        -- Finished with guide prefix. Now join all prefix chars by a space
        local pref_str = table.concat(pref, " ")
        local total_pref_len = lineno_offset + #pref_str

        -- Guide hl goes from start of prefix till before the fold marker, if any.
        -- Fold hl goes from start of fold marker until before the icon.
        save_guide_hl(lineno_offset, total_pref_len - fold_marker_width)
        if fold_marker_width > 0 then
          save_fold_hl(total_pref_len - fold_marker_width, total_pref_len + 1)
        end

        local line = lineno_prefix .. pref_str
        local icon_pref = 0
        if node.icon ~= "" then
          line = line .. " " .. node.icon
          icon_pref = 1
        end
        -- 修改了此行,此处是去空格
        line = line .. node.name

        -- Start from left of icon col
        local hl_start = #pref_str + #lineno_prefix + icon_pref
        local hl_end = hl_start + #node.icon -- until after icon
        local hl_type = cfg.o.symbols.icons[symbols.kinds[node.kind]].hl
        table.insert(hl, {
          line = line_count,
          name = hl_type,
          from = hl_start,
          to = hl_end,
        })
        -- Prefix length is from start until the beginning of the node.name, used
        -- for hover highlights.
        -- 修改了此行,此处是修改高亮
        node.prefix_length = hl_end

        -- Each line passed to nvim_buf_set_lines cannot contain newlines
        line = line:gsub("\n", " ")
        table.insert(lines, line)
      end

      self.view:clear_all_ns()
      self.view:rewrite_lines(lines)
      self.view:add_hl_and_ns(hl, self.flats, details, linenos)

      return put_cursor
    end
  end,
}

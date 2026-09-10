-- linter-formatter-info.lua
-- LSP・Conform・ファイルタイプ情報を表示する設定

local info = require("config.linter-formatter-info")

-- floatウィンドウを作成・表示する関数
local function show_info_float()
  local bufnr = vim.api.nvim_get_current_buf()
  local data = info.get_all_info(bufnr)
  
  -- コンテンツを構築
  local lines = {}
  
  -- ヘッダー
  table.insert(lines, "🔧 Linter/Formatter Information")
  table.insert(lines, "")
  
  -- ファイル情報
  table.insert(lines, "📄 File Info:")
  table.insert(lines, string.format("  • Name: %s", data.file.filename))
  table.insert(lines, string.format("  • Type: %s", data.file.filetype))
  table.insert(lines, string.format("  • Encoding: %s", data.file.encoding))
  table.insert(lines, string.format("  • Format: %s", data.file.format))
  table.insert(lines, "")
  
  -- LSP情報
  table.insert(lines, "🔧 LSP Clients:")
  if #data.lsp > 0 then
    for _, client in ipairs(data.lsp) do
      table.insert(lines, string.format("  • %s", client.name))
      if client.capabilities.formatting then
        table.insert(lines, "    ✅ Formatting")
      end
      if client.capabilities.hover then
        table.insert(lines, "    ✅ Hover")
      end
      if client.capabilities.rename then
        table.insert(lines, "    ✅ Rename")
      end
      if client.capabilities.code_action then
        table.insert(lines, "    ✅ Code Actions")
      end
    end
  else
    table.insert(lines, "  • No LSP clients attached")
  end
  table.insert(lines, "")
  
  -- 診断情報
  table.insert(lines, "🩺 Diagnostics:")
  local diag = data.diagnostics
  if diag.error + diag.warn + diag.info + diag.hint > 0 then
    if diag.error > 0 then
      table.insert(lines, string.format("  • ❌ Errors: %d", diag.error))
    end
    if diag.warn > 0 then
      table.insert(lines, string.format("  • ⚠️  Warnings: %d", diag.warn))
    end
    if diag.info > 0 then
      table.insert(lines, string.format("  • ℹ️  Info: %d", diag.info))
    end
    if diag.hint > 0 then
      table.insert(lines, string.format("  • 💡 Hints: %d", diag.hint))
    end
  else
    table.insert(lines, "  • ✅ No issues found")
  end
  table.insert(lines, "")
  
  -- フォーマッタ情報
  table.insert(lines, "🎨 Formatters:")
  if data.formatters.available then
    if #data.formatters.formatters > 0 then
      for _, formatter in ipairs(data.formatters.formatters) do
        local status = formatter.available and "✅" or "❌"
        table.insert(lines, string.format("  • %s %s", status, formatter.name))
      end
    else
      table.insert(lines, "  • No formatters configured for this filetype")
    end
  else
    table.insert(lines, "  • Conform not available")
  end
  table.insert(lines, "")
  
  -- Tree-sitter情報
  table.insert(lines, "🌲 Tree-sitter:")
  if data.treesitter.available then
    if data.treesitter.parser_available then
      table.insert(lines, string.format("  • ✅ Parser: %s", data.treesitter.filetype))
      if data.treesitter.highlighting ~= nil then
        local hl_status = data.treesitter.highlighting and "✅" or "❌"
        table.insert(lines, string.format("  • %s Highlighting", hl_status))
      end
    else
      table.insert(lines, string.format("  • ❌ No parser for %s", data.treesitter.filetype))
    end
  else
    table.insert(lines, "  • Tree-sitter not available")
  end
  
  -- ウィンドウサイズを動的に計算
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
  end
  
  local width = math.min(max_width + 4, math.floor(vim.o.columns * 0.7))
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.6))
  
  -- floatウィンドウの設定
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = 'rounded',
    style = 'minimal',
    title = ' Linter/Formatter Info ',
    title_pos = 'center'
  }
  
  -- バッファを作成してコンテンツを設定
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = 'linter-formatter-info'
  
  -- ウィンドウを作成
  local win = vim.api.nvim_open_win(buf, true, opts)
  
  -- ウィンドウのキーマップを設定（qまたはESCで閉じる）
  local function close_win()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  
  vim.keymap.set('n', 'q', close_win, { buffer = buf, noremap = true, silent = true })
  vim.keymap.set('n', '<Esc>', close_win, { buffer = buf, noremap = true, silent = true })
end

-- グローバル関数として公開（which-keyから呼び出し用）
_G.show_linter_formatter_info = show_info_float

-- コマンドを作成
vim.api.nvim_create_user_command('LinterFormatterInfo', show_info_float, {
  desc = 'Show linter and formatter information for current buffer'
})

-- プラグインテーブルは空で返す（lazy.nvim用）
return {}
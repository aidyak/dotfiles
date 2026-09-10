-- linter-formatter-info.lua
-- LSP・Conform・ファイルタイプ情報を収集するモジュール

local M = {}

-- LSP クライアント情報を取得
function M.get_lsp_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local lsp_info = {}
  
  if #clients > 0 then
    for _, client in ipairs(clients) do
      table.insert(lsp_info, {
        name = client.name,
        capabilities = {
          formatting = client.server_capabilities.documentFormattingProvider or false,
          hover = client.server_capabilities.hoverProvider or false,
          rename = client.server_capabilities.renameProvider or false,
          code_action = client.server_capabilities.codeActionProvider or false,
        }
      })
    end
  end
  
  return lsp_info
end

-- 診断情報を取得
function M.get_diagnostic_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end
  
  return counts
end

-- Conform フォーマッタ情報を取得
function M.get_formatter_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  
  -- Conformが利用可能かチェック
  local conform_ok, conform = pcall(require, "conform")
  if not conform_ok then
    return { available = false }
  end
  
  -- フォーマッタ一覧を取得
  local formatters = conform.list_formatters(bufnr)
  local formatter_info = {
    available = true,
    filetype = filetype,
    formatters = {}
  }
  
  for _, formatter in ipairs(formatters) do
    table.insert(formatter_info.formatters, {
      name = formatter.name,
      available = formatter.available,
      command = formatter.command
    })
  end
  
  return formatter_info
end

-- Tree-sitter 情報を取得
function M.get_treesitter_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  
  -- Tree-sitterが利用可能かチェック
  local ts_ok, ts = pcall(require, "nvim-treesitter.parsers")
  if not ts_ok then
    return { available = false }
  end
  
  -- 新しいAPIに対応: has_parser -> get_parser_configs
  local parser_available = false
  local configs_ok, configs = pcall(ts.get_parser_configs)
  if configs_ok and configs then
    parser_available = configs[filetype] ~= nil
  else
    -- フォールバック: vim.treesitter.get_parser を試行
    local parser_ok = pcall(vim.treesitter.get_parser, bufnr, filetype)
    parser_available = parser_ok
  end
  
  local parser_info = {
    available = true,
    filetype = filetype,
    parser_available = parser_available
  }
  
  -- パーサーが利用可能な場合、追加情報を取得
  if parser_available then
    local highlighter_ok, highlighter = pcall(require, "nvim-treesitter.highlight")
    if highlighter_ok then
      parser_info.highlighting = highlighter.is_enabled(bufnr)
    end
  end
  
  return parser_info
end

-- ファイル基本情報を取得
function M.get_file_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  return {
    filetype = vim.bo[bufnr].filetype,
    encoding = vim.bo[bufnr].fileencoding == '' and 'utf-8' or vim.bo[bufnr].fileencoding,
    format = vim.bo[bufnr].fileformat,
    filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')
  }
end

-- 全情報を統合して取得
function M.get_all_info(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  return {
    file = M.get_file_info(bufnr),
    lsp = M.get_lsp_info(bufnr),
    diagnostics = M.get_diagnostic_info(bufnr),
    formatters = M.get_formatter_info(bufnr),
    treesitter = M.get_treesitter_info(bufnr)
  }
end

return M

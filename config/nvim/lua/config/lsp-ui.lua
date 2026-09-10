-- "No information available" を非表示にするカスタム hover ハンドラ
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  if err or not result or not result.contents then
    return
  end
  local value = ""
  if type(result.contents) == "string" then
    value = result.contents
  elseif result.contents.value then
    value = result.contents.value
  end
  if value == "" or value == "No information available" then
    return
  end
  config = config or {}
  config.border = "rounded"
  vim.lsp.handlers.hover(err, result, ctx, config)
end

-- signature help にもボーダーを設定
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
})

-- 例: lua/config/lsp-ui.lua などに置く（どこでもOK）
local function has_hover_support(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.supports_method and client:supports_method("textDocument/hover") then
      return true
    end
  end
  return false
end

local function has_floating_win()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" then
      return true
    end
  end
  return false
end

local function should_auto_hover(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft ~= "typescript" and ft ~= "typescriptreact" then
    return false
  end
  if vim.fn.mode() ~= "n" then
    return false
  end
  if has_floating_win() then
    return false
  end
  return has_hover_support(bufnr)
end

local function preview_definition()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      return
    end
    local location = result
    if vim.tbl_islist(result) then
      location = result[1]
    end
    if vim.lsp.util.preview_location then
      vim.lsp.util.preview_location(location, { border = "rounded" })
      return
    end
    vim.lsp.util.jump_to_location(location, "utf-8")
  end)
end

-- Hover を出しやすくする
vim.opt.updatetime = 300

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    local opts = { buffer = buf, silent = true }
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- 基本
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "gp", preview_definition, opts)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({ border = "rounded" })
    end, opts)

    -- 編集系
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

    -- 診断
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

    vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

    if client and client.name == "rust_analyzer" and vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    end
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if should_auto_hover(buf) then
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf_request(buf, "textDocument/hover", params, function(err, result)
        if err or not result or not result.contents then
          return
        end
        local value = ""
        if type(result.contents) == "string" then
          value = result.contents
        elseif result.contents.value then
          value = result.contents.value
        end
        if value == "" or value == "No information available" then
          return
        end
        vim.lsp.buf.hover({ border = "rounded" })
      end)
    end
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = {
    severity = vim.diagnostic.severity.ERROR,
  },
  update_in_insert = false,
  float = {
    border = "rounded",
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    -- 自動フォーマットを無効にするファイルタイプ
    local skip_format = {
      ruby = true,
      typescript = true,
      typescriptreact = true,
    }
    if skip_format[ft] then
      return
    end
    vim.lsp.buf.format({ bufnr = args.buf })
  end,
})

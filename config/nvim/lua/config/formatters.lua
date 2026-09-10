local M = {}

local function has_root_file(bufnr, files)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start_path = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h") or vim.fn.getcwd()
  local found = vim.fs.find(files, { path = start_path, upward = true, limit = 1 })
  return #found > 0
end

-- -------------------------
-- TypeScript / JavaScript / TSX
-- package.jsonのscriptsやdependenciesも考慮した判定
-- -------------------------
function M.ts(bufnr)
  -- package.jsonの場所を取得
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local start_path = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h") or vim.fn.getcwd()
  local found = vim.fs.find("package.json", { path = start_path, upward = true, limit = 1 })
  if #found > 0 then
    local package_json_path = found[1]
    -- ファイルが存在するかチェック
    if vim.fn.filereadable(package_json_path) == 1 then
      local ok, package_content = pcall(vim.fn.readfile, package_json_path)
      if ok and package_content then
        local package_text = table.concat(package_content, "\n")
        
        -- Prettierがメインの場合を先にチェック（より確実な検出）
        if package_text:match('"prettier"') or 
           package_text:match('"format":[%s]*"[^"]*prettier') or
           package_text:match('"@prettier/') then
          if has_root_file(bufnr, {
            "prettier.config.js",
            "prettier.config.cjs", 
            "prettier.config.mjs",
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.js",
            ".prettierrc.cjs",
            ".prettierrc.yaml",
            ".prettierrc.yml",
          }) then
            return { "prettierd", "prettier", stop_after_first = true }
          end
        end
        
        -- Biomeがメインの場合（Prettierが見つからなかった場合のみ）
        if package_text:match('"@biomejs/biome"') or 
           package_text:match('"biome":[%s]*"[^"]*format') or
           package_text:match('"format":[%s]*"[^"]*biome') then
          if has_root_file(bufnr, { "biome.json", "biome.jsonc" }) then
            return { "biome" }
          end
        end
      end
    end
  end

  -- package.jsonで判定できない場合は設定ファイルの存在のみで判定
  -- Prettier設定ファイルがある場合を優先
  if has_root_file(bufnr, {
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.yaml",
    ".prettierrc.yml",
  }) then
    return { "prettierd", "prettier", stop_after_first = true }
  end

  -- Biome設定ファイルがある場合
  if has_root_file(bufnr, { "biome.json", "biome.jsonc" }) then
    return { "biome" }
  end

  -- OXC設定ファイルがある場合
  if has_root_file(bufnr, { ".oxcrc", "oxc.config.json" }) then
    return { "oxc" }
  end

  -- 何も見つからなければ LSP fallback
  return {}
end

-- -------------------------
-- Ruby
-- 優先: standardrb -> rubocop -> (なし = LSP fallback)
-- （好みで順番を入れ替えてOK）
-- -------------------------
function M.ruby(bufnr)
  -- StandardRB（Gemfile / .standard.yml など）
  if has_root_file(bufnr, { ".standard.yml", ".standard.yaml" }) then
    return { "standardrb" }
  end

  -- RuboCop（.rubocop.yml / Gemfile など）
  if has_root_file(bufnr, { ".rubocop.yml", ".rubocop_todo.yml" }) then
    return { "rubocop" }
  end

  -- どっちも無ければ LSP fallback
  return {}
end

-- -------------------------
-- Rust
-- 基本: rustfmt（Rustはプロジェクトごとに大きく揺れない）
-- ただし rustfmt の設定ファイルがある場合だけ強制したい、なども可
-- -------------------------
function M.rust(bufnr)
  -- rustfmt.toml があれば rustfmt を明示（無くても通常はOK）
  if has_root_file(bufnr, { "rustfmt.toml" }) then
    return { "rustfmt" }
  end
  -- Cargoプロジェクトなら rustfmt を使う（cargo fmt）
  if has_root_file(bufnr, { "Cargo.toml" }) then
    return { "rustfmt" }
  end
  return {}
end

return M


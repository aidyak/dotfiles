return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        -- Rubyファイルはフォーマットしない
        if ft == "ruby" then
          return
        end
        return {
          timeout_ms = 2000,
          -- 外部フォーマッタが見つからない時だけ LSP にフォールバック
          lsp_format = "fallback",
        }
      end,

      formatters_by_ft = {
        -- TypeScript / JS
        javascript = function(bufnr) return require("config.formatters").ts(bufnr) end,
        javascriptreact = function(bufnr) return require("config.formatters").ts(bufnr) end,
        typescript = function(bufnr) return require("config.formatters").ts(bufnr) end,
        typescriptreact = function(bufnr) return require("config.formatters").ts(bufnr) end,
        tsx = function(bufnr) return require("config.formatters").ts(bufnr) end,

        -- Ruby
        ruby = function(bufnr) return require("config.formatters").ruby(bufnr) end,

        -- Rust
        rust = function(bufnr) return require("config.formatters").rust(bufnr) end,

        -- Lua
        lua = { "stylua" },

        -- Nix
        nix = { "nixfmt" },

        -- Python
        python = { "ruff_format" },

        -- Elixir
        elixir = { "mix" },
        heex = { "mix" },

        -- Go
        go = { "goimports", "gofumpt" },
      },
    },
  },
}


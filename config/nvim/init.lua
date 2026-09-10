-- Leaderキー設定（必ず lazy.nvim より前）
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- vim.lsp.set_log_level("trace")
require("config.lazy")
require("config.lsp-ui")
require("config.options")
-- require("config.colorscheme")

-- lua/config/options.lua
local opt = vim.opt

opt.number = true
opt.relativenumber = true
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
opt.expandtab, opt.tabstop, opt.shiftwidth = true, 2, 2
opt.inccommand = "split"
opt.cmdheight = 0
vim.lsp.log.set_level(vim.log.levels.WARN)
-- plugins/ディレクトリに新規luaファイルを作成したら自動でテンプレート挿入
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*/nvim/lua/plugins/*.lua",
	callback = function()
		vim.api.nvim_buf_set_lines(0, 0, 0, false, { "return {", "}", "" })
		vim.api.nvim_win_set_cursor(0, { 2, 0 })
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.formatoptions:append("r")
	end,
})
vim.filetype.add({
	extension = {
		mdx = "mdx",
	},
})
vim.treesitter.language.register("mdx", "mdx")
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
		lazy = false,
		priority = 1000,
		config = function()
			vim.list = vim.list or {}
			vim.list.unique = vim.list.unique
				or function(items)
					local seen = {}
					local unique = {}
					for _, item in ipairs(items) do
						if not seen[item] then
							seen[item] = true
							table.insert(unique, item)
						end
					end
					return unique
				end

			local languages = {
				"lua",
				"vim",
				"vimdoc",
				"bash",
				"json",
				"yaml",
				"markdown",
				"markdown_inline",
				"javascript",
				"typescript",
				"tsx",
				"python",
				"rust",
				"toml",
				"elixir",
				"eex",
				"heex",
				"go",
				"gomod",
				"gosum",
				"gowork",
			}

			local install_task = require("nvim-treesitter").install(languages)

			local function start_treesitter(bufnr)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local parser_ok, parser = pcall(vim.treesitter.get_parser, bufnr)
				if not parser_ok or not parser then
					return
				end

				pcall(vim.treesitter.start, bufnr)
				local query_ok, query = pcall(vim.treesitter.query.get, parser:lang(), "indents")
				if query_ok and query then
					vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true }),
				callback = function(args)
					start_treesitter(args.buf)
				end,
			})

			if vim.bo.filetype ~= "" then
				start_treesitter()
			end

			-- 初回導入した言語はパーサーのビルドが非同期で走るため、
			-- 開いたタイミングでは間に合わずハイライトが付かないことがある。
			-- インストール完了後に、既存バッファへ一度だけ再適用する。
			install_task:await(function()
				for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype ~= "" then
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(bufnr) then
								start_treesitter(bufnr)
							end
						end)
					end
				end
			end)
		end,
	},
}

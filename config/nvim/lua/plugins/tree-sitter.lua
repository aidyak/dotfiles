return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
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
				bufnr = bufnr or 0
				pcall(vim.treesitter.start, bufnr)
				vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					start_treesitter(args.buf)
				end,
			})

			if vim.bo.filetype ~= "" then
				start_treesitter(0)
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

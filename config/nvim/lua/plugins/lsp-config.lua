-- lua/plugins/lsp-config.lua
-- LSPサーバーはすべてNix (home.nix) で管理。Masonはインストール済みバイナリの
-- PATHブリッジとしてのみ使い、ensure_installed / automatic_installation は無効。
return {
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim" },
		opts = {
			ensure_installed = {},
			automatic_installation = false,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			capabilities.workspace = capabilities.workspace or {}
			capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }

			local function ruby_lsp_cmd(root_dir)
				if root_dir and vim.fs.find({ "compose.yml", "compose.yaml", "docker-compose.yml", "docker-compose.yaml" }, {
					path = root_dir,
					upward = false,
				})[1] then
					return { "docker", "compose", "exec", "-T", "backend", "bundle", "exec", "ruby-lsp" }
				end

				return { "/opt/homebrew/bin/mise", "exec", "--", "ruby-lsp" }
			end

			-- 重複起動を避けるため vtsls を明示的に無効化
			if vim.lsp.disable then
				vim.lsp.disable("vtsls")
			end
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "vtsls" then
						vim.lsp.stop_client(client.id)
					end
				end,
			})

			-- サーバ個別の上書き/追加設定は vim.lsp.config
			vim.lsp.config("*", {
				capabilities = capabilities,
				cmd_env = { NODE_NO_WARNINGS = "1" },
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			-- ruby-lsp（solargraphより補完・定義ジャンプが安定）
			vim.lsp.config("ruby_lsp", {
				cmd = function(dispatchers, config)
					return vim.lsp.rpc.start(
						ruby_lsp_cmd(config and config.root_dir),
						dispatchers,
						config and config.root_dir and { cwd = config.cmd_cwd or config.root_dir }
					)
				end,
				init_options = {
					enabledFeatures = {
						"codeActions",
						"completion",
						"definition",
						"diagnostics",
						"documentHighlights",
						"documentSymbols",
						"formatting",
						"hover",
						"inlayHint",
						"references",
						"rename",
						"signatureHelp",
					},
				},
				settings = {
					rubyLsp = {
						rubyVersionManager = {
							identifier = "mise",
							miseExecutablePath = "/opt/homebrew/bin/mise",
						},
					},
				},
			})

			-- elixir-ls（mise管理のバイナリを利用。asdf/mise-elixir-lsが bin/elixir-ls を language_server.sh へ提供）
			vim.lsp.config("elixirls", {
				cmd = { "/opt/homebrew/bin/mise", "exec", "--", "elixir-ls" },
			})

			-- gopls（mise管理。gopls自体はmiseのgoプラグインが入れるdefault-golang-packages経由でGOBINに入る想定）
			vim.lsp.config("gopls", {
				cmd = { "/opt/homebrew/bin/mise", "exec", "--", "gopls" },
				settings = {
					gopls = {
						gofumpt = true,
						staticcheck = true,
						usePlaceholders = true,
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							constantValues = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			})

			vim.lsp.config("rust_analyzer", {
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
						},
						checkOnSave = true,
						check = {
							command = "clippy",
							extraArgs = { "--all-targets" },
						},
						procMacro = {
							enable = true,
						},
						inlayHints = {
							bindingModeHints = {
								enable = true,
							},
							closureCaptureHints = {
								enable = true,
							},
							closureReturnTypeHints = {
								enable = "always",
							},
							discriminantHints = {
								enable = "always",
							},
							lifetimeElisionHints = {
								enable = "skip_trivial",
								useParameterNames = true,
							},
							typeHints = {
								enable = true,
								hideClosureInitialization = false,
								hideNamedConstructor = false,
							},
						},
					},
				},
			})

			-- 有効化（solargraph → ruby_lsp に変更）
			vim.lsp.enable({ "lua_ls", "pyright", "ruby_lsp", "rubocop", "ts_ls", "rust_analyzer", "nil_ls", "elixirls", "gopls" })
		end,
	},
}

local M = {}

M.schemes = {
	"tokusa",
	"nautilus",
	"habamax",
	"cyberdream",
}

local function index_of(current)
	for i, name in ipairs(M.schemes) do
		if name == current then
			return i
		end
	end
	return 0
end

function M.pick()
	if #M.schemes == 0 then
		vim.notify("colorscheme list is empty", vim.log.levels.WARN)
		return
	end

	local current = vim.g.colors_name
	local prompt = "Select colorscheme"

	if vim.ui and vim.ui.select then
		vim.ui.select(M.schemes, { prompt = prompt, default = current }, function(choice)
			if not choice then
				return
			end
			local ok = pcall(vim.cmd.colorscheme, choice)
			if ok then
				vim.notify("colorscheme: " .. choice, vim.log.levels.INFO)
			else
				vim.notify("colorscheme failed: " .. choice, vim.log.levels.WARN)
			end
		end)
		return
	end

	local choices = { prompt }
	for _, name in ipairs(M.schemes) do
		table.insert(choices, name)
	end

	local idx = vim.fn.inputlist(choices)
	local choice = M.schemes[idx]
	if not choice then
		return
	end

	local ok = pcall(vim.cmd.colorscheme, choice)
	if ok then
		vim.notify("colorscheme: " .. choice, vim.log.levels.INFO)
	else
		vim.notify("colorscheme failed: " .. choice, vim.log.levels.WARN)
	end
end

vim.api.nvim_create_user_command("ToggleColorscheme", M.pick, {})

return M

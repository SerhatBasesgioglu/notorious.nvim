local M = {}
local cfg = require("notorious.config")

function M.search()
	local notes_dir = cfg.notes_dir
	local handle = io.popen(string.format("rg --no-heading --line-number --color=never '' %s", notes_dir))
	local results = {}

	if handle then
		for line in handle:lines() do
			table.insert(results, line)
		end
		handle:close()
	end

	if #results == 0 then
		local find = io.popen(string.format("find %s -type f -name '*.md'", notes_dir))
		for line in find:lines() do
			table.insert(results, line)
		end
		find:close()
	end

	vim.ui.select(results, { prompt = "Select note to open: " }, function(choice)
		if not choice then
			return
		end
		local file = choice:match("^(.-):") or choice
		vim.cmd("e " .. file)
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("NotoriousSearch", M.search, { desc = "Search Note" })
end

return M

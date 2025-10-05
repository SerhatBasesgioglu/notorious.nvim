local M = {}

function M.reload()
	for name, _ in pairs(package.loaded) do
		if name:match("^notorious") then
			package.loaded[name] = nil
		end
	end

	require("notorious").setup()
	vim.notify("Notorious reloaded", vim.log.levels.INFO)
end

return M

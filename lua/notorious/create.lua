local M = {}

local cfg = require("notorious.config")

local notes_dir = cfg.notes_dir
local extension = cfg.extension

local function random_id()
	local t = {}
	for _ = 1, 4 do
		table.insert(t, string.char(math.random(97, 122)))
	end
	return table.concat(t)
end

local function ensure_normal_window()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "buftype") == "" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.cmd("new")
end

function M.new_note()
	local title = vim.fn.input("Title: ")
	if title == "" then
		print("Cancelled")
		return
	end

	vim.fn.mkdir(notes_dir, "p")

	local id = os.date("%Y%m%d") .. "-" .. random_id()
	local filename = string.format("%s%s", title:gsub("%s+", "-"):lower(), extension)
	local path = notes_dir .. "/" .. filename

	if vim.fn.filereadable(path) == 1 then
		vim.notify("Note already exists: " .. path, vim.log.levels.ERROR)
		return
	end

	local header = {
		"---",
		"id: " .. id,
		"title: " .. title,
		"tags: []",
		"created " .. os.date("%Y-%m-%d %H:%M"),
		"---",
		"",
		"# " .. title,
		"",
	}

	ensure_normal_window()
	vim.cmd("e " .. path)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, header)
	local last_line = vim.api.nvim_buf_line_count(0)
	vim.api.nvim_win_set_cursor(0, { last_line, 0 })
	print("Note Created: " .. path)
end

function M.setup()
	vim.api.nvim_create_user_command("NotoriousNew", M.new_note, { desc = "Craete new note" })
end

return M

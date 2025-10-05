local M = {}
local cfg = require("notorious.config")

local function get_header_lines(limit)
	return vim.api.nvim_buf_get_lines(0, 0, limit, false)
end

local function set_header_lines(lines)
	vim.api.nvim_buf_set_lines(0, 0, #lines, false, lines)
end

local function parse_tags()
	local lines = get_header_lines(20)
	for _, line in ipairs(lines) do
		if line:match("^tags:") then
			local content = line:gsub("^tags:%s*", "")
			local tags = {}
			for tag in content:gmatch("[%w-_]+") do
				table.insert(tags, tag)
			end
			return tags
		end
	end
	return {}
end

local function write_tags(tags)
	local lines = get_header_lines(20)
	local found = false
	for i, line in ipairs(lines) do
		if line:match("^tags:") then
			lines[i] = "tags: [" .. table.concat(tags, ", ") .. "]"
			found = true
			break
		end
	end
	if not found then
		table.insert(lines, 4, "tags: [" .. table.concat(tags(", ")) .. "]")
	end
	set_header_lines(lines)
	if cfg.auto_save then
		vim.cmd("w")
	end
end

local function collect_all_tags()
	local notes_dir = cfg.notes_dir
	local cmd = string.format("rg --no-heading --only-matching '^tags:.*' %q", notes_dir)
	local handle = io.popen(cmd)
	if not handle then
		return {}
	end

	local tagset = {}
	for line in handle:lines() do
		local inside = line:match("%[(.-)%]")
		if inside then
			for tag in inside:gmatch("[^,%s]+") do
				if tag ~= "tags" then
					tagset[tag] = true
				end
			end
		end
	end
	handle:close()

	local tags = {}
	for tag in pairs(tagset) do
		table.insert(tags, tag)
	end
	table.sort(tags)
	return tags
end

function M.list_tags()
	local tags = parse_tags()
	if #tags == 0 then
		vim.notify("No tags in this note", vim.log.levels.INFO)
		return
	end
	vim.notify("Tags:" .. table.concat(tags, ", "), vim.log.levels.INFO)
end

function M.add_tag(tag)
	local all_tags = collect_all_tags()

	vim.ui.select(all_tags, { prompt = "Choose existing tag or <Esc> to type new:" }, function(choice)
		if choice then
			tag = choice
		else
			tag = vim.fn.input("New tag: ")
		end
		if tag == "" then
			return
		end
		local tags = parse_tags()
		for _, t in ipairs(tags) do
			if t == tag then
				vim.notify("Tag already exists: " .. tag, vim.log.levels.WARN)
				return
			end
		end
		table.insert(tags, tag)
		write_tags(tags)
		vim.notify("Added tag: " .. tag, vim.log.levels.INFO)
	end)
end

function M.search_tag(tag)
	if not tag or tag == "" then
		tag = vim.fn.input("Search tag: ")
	end
	if tag == "" then
		return
	end

	local notes_dir = cfg.notes_dir
	local cmd = string.format("rg --files-with-matches '^tags:.*%s' %q", tag, notes_dir)
	local handle = io.popen(cmd)
	local results = {}
	for line in handle:lines() do
		table.insert(results, line)
	end
	handle:close()

	if #results == 0 then
		vim.notify("No notes with tag: " .. tag, vim.log.levels.INFO)
		return
	end

	vim.ui.select(results, { prompt = "Select note tagged " .. tag .. ":" }, function(choice)
		if choice then
			vim.cmd("e " .. choice)
		end
	end)
end

function M.setup()
	vim.api.nvim_create_user_command("NotoriousTags", M.list_tags, { desc = "List tags in current note" })
	vim.api.nvim_create_user_command("NotoriousAddTag", function(opts)
		M.add_tag(opts.args)
	end, { nargs = "?", desc = "Add tag to current note" })
	vim.api.nvim_create_user_command("NotoriousTagSearch", function(opts)
		M.search_tag(opts.args)
	end, { nargs = "?", desc = "Search notes by tag" })
end

return M

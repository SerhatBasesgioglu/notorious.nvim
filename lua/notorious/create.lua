local M = {}

local cfg = require("notorious.config")

local notes_dir = cfg.notes_dir
local extension = cfg.extension

local function list_notes()
  local files = vim.fn.globpath(notes_dir, "**" .. extension, false, true)
  local names = {}
  for _, f in ipairs(files) do
    local name = vim.fn.fnamemodify(f, ":t:r")
    table.insert(names, { text = name, file = f })
  end
  return names
end

local function find_note(title)
  local slug = title:gsub("%s+", "-")
  local path = notes_dir .. "/" .. slug .. extension
  if vim.fn.filereadable(path) == 1 then
    return path
  end
  return nil
end

function M.pick_or_create_new_note()
  local notes = list_notes()
  Snacks.picker.pick({
    items = notes,
    title = "Select or Create New Note",
    confirm = function(picker, item)
      local query = picker.input.filter.pattern
      picker:close()
      if item then
        print(item.text)
        vim.cmd("edit " .. item.file)
      else
        local title = vim.fn.fnamemodify(query, ":t:r")
        local new_file = notes_dir .. "/" .. title .. extension

        if vim.fn.filereadable(new_file) == 0 then
          vim.fn.writefile({}, new_file)
        end
        vim.cmd("edit " .. new_file)

        local header = {
          "---",
          "title: " .. title,
          "type: " .. "reference",
          "status: " .. "inprogress",
          "createdAt: " .. os.date("%Y-%m-%dT%H:%M:%S"),
          "updatedAt: " .. os.date("%Y-%m-%dT%H:%M:%S"),
          "related: ",
          "---",
        }

        vim.api.nvim_buf_set_lines(0, 0, -1, false, header)
        vim.cmd("write")
      end
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command("NotoriousNew", M.pick_or_create_new_note, { desc = "Craete new note" })
end

return M

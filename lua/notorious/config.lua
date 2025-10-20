local M = {}

M.notes_dir = vim.fn.expand("~/repos/notes/notes")
M.extension = ".md"
M.auto_save = true
M.auto_cursor_bottom = true

M.valid = {
    type = { "reference", "tutorial", "project", "task", "log" },
    note_status = { "draft", "inprogress", "review", "completed", "stale" },
    task_status = { "backlog", "todo", "inprogress", "onhold", "review", "completed" },
    priority = { "urgent", "high", "medium", "low", "none" },
}
return M

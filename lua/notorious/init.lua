local M = {}

function M.setup()
  require("notorious.create").setup()
  require("notorious.search").setup()
  require("notorious.tags").setup()

  vim.api.nvim_create_user_command("NotoriousHello", function()
    print("Notorious is here bois")
  end, {})

  vim.keymap.set("n", "<leader>nr", function()
    require("notorious.dev").reload()
  end, { desc = "Reload Notorious Plugin" })

  vim.keymap.set("n", "<leader>nn", function()
    require("notorious.create").pick_or_create_new_note()
  end, { desc = "Create new Note" })

  vim.keymap.set("n", "<leader>nf", function()
    require("notorious.search").search()
  end)

  vim.keymap.set("n", "<leader>nt", function()
    require("notorious.tags").add_tag()
  end)

  vim.keymap.set("n", "<leader>nl", function()
    require("notorious.tags").list_tags()
  end, { desc = "List tags of current buffer" })

  vim.keymap.set("n", "<leader>ns", function()
    require("notorious.tags").search_tag()
  end, { desc = "Search tags" })
end

return M

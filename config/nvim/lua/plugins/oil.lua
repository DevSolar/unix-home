return {
  "stevearc/oil.nvim",
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory in Oil" },
    { "<leader>-", "<cmd>Oil --float<cr>", desc = "Open parent directory (floating popup)" },
  },
  opts = {
    -- Replaces netrw as the default directory viewer
    default_file_explorer = true,
    delete_to_trash = false,
    skip_confirm_for_simple_edits = true,
    view_options = {
      -- Show hidden files by default (toggle with 'g.')
      show_hidden = false,
    },
    float = {
      padding = 2,
      max_width = 90,
      max_height = 25,
      border = "rounded",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-s>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
  },
}

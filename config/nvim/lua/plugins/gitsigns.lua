return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Unstaged working-tree signs (highlighted via GitSigns* in colorscheme)
    signs = {
      add          = { text = "▶" },
      change       = { text = "◆" },
      delete       = { text = "◁" },
      topdelete    = { text = "△" },
      changedelete = { text = "◇" },
      untracked    = { text = "▷" },
    },
    -- Staged index signs (highlighted via GitSignsStaged* in colorscheme)
    signs_staged = {
      add          = { text = "▶" },
      change       = { text = "◆" },
      delete       = { text = "◁" },
      topdelete    = { text = "△" },
      changedelete = { text = "◇" },
    },
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation between hunks
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gitsigns.next_hunk() end)
        return "<Ignore>"
      end, "Next git hunk")

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return "<Ignore>"
      end, "Previous git hunk")

      -- Actions
      map("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
      map("n", "<leader>hp", gitsigns.preview_hunk, "Preview hunk diff")
      map("n", "<leader>hb", function() gitsigns.blame_line({ full = true }) end, "Blame line (popup)")
      map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Toggle ghost-text inline blame")
    end,
  },
}

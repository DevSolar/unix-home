return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Dashboard
    dashboard = {
      enabled = true,
      preset = {
        header = [[
██╗   ██╗██╗███╗   ███╗
██║   ██║██║████╗ ████║
██║   ██║██║██╔████╔██║
╚██╗ ██╔╝██║██║╚██╔╝██║
 ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        keys = {
          { icon = "▶ ", key = "f", desc = "Find File", action = ":Telescope find_files" },
          { icon = "◆ ", key = "g", desc = "Live Grep", action = ":Telescope live_grep" },
          { icon = "▷ ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
          { icon = "◇ ", key = "e", desc = "File Explorer", action = ":Oil" },
          { icon = "⚙ ", key = "c", desc = "Config", action = ":lua require('oil').open(vim.fn.stdpath('config'))" },
          { icon = "✕ ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        -- Pane 1: Keymappings Reference
        -- (Uncomment below if you wish to display the ASCII art banner above the keymaps)
        -- { section = "header" },

        { pane = 1, title = "Find & Browse", padding = 1 },
        { pane = 1, icon = " ", desc = "Find Files",     label = "<leader>ff", action = ":Telescope find_files" },
        { pane = 1, icon = " ", desc = "Live Grep",      label = "<leader>fg", action = ":Telescope live_grep" },
        { pane = 1, icon = " ", desc = "Recent Files",   label = "<leader>fo", action = ":Telescope oldfiles" },
        { pane = 1, icon = " ", desc = "Buffers",        label = "<leader>fb", action = ":Telescope buffers" },
        { pane = 1, icon = " ", desc = "File Explorer",  label = "-",          action = ":Oil" },
        { pane = 1, icon = " ", desc = "Float Explorer", label = "<leader>-",  action = ":Oil --float" },

        { pane = 1, title = "LSP & Code", padding = 1 },
        { pane = 1, icon = "󰈈 ", desc = "Definition",      label = "gd" },
        { pane = 1, icon = "󰒕 ", desc = "References",      label = "gr" },
        { pane = 1, icon = "󰋖 ", desc = "Hover Docs",      label = "K" },
        { pane = 1, icon = "󰌵 ", desc = "Code Action",     label = "<leader>ca" },
        { pane = 1, icon = "󰑕 ", desc = "Rename Symbol",   label = "<leader>rn" },
        { pane = 1, icon = " ", desc = "Next Diagnostic", label = "]d" },

        { pane = 1, title = "Git & Editing", padding = 1 },
        { pane = 1, icon = " ", desc = "Next Hunk",        label = "]c" },
        { pane = 1, icon = " ", desc = "Stage Hunk",       label = "<leader>hs" },
        { pane = 1, icon = " ", desc = "Preview Diff",     label = "<leader>hp" },
        { pane = 1, icon = "󰊢 ", desc = "Toggle Blame",     label = "<leader>tb" },
        { pane = 1, icon = "󰛐 ", desc = "Toggle Dim",       label = "<leader>td" },
        { pane = 1, icon = "󰌒 ", desc = "CamelCase Nav",    label = "<C-h/l>" },

        { pane = 1, section = "startup", padding = 1 },

        -- Pane 2: GitHub & Repository
        {
          pane = 2,
          icon = " ",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
        },
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              title = "Notifications",
              cmd = [[gh api notifications --jq '.[0:3] | .[] | "\(.repository.full_name)\((.subject.url // "") | split("/") | last | if . != "" then " #" + . else "" end)\n    \(if (.subject.title | length) > 48 then .subject.title[0:45] + "..." else .subject.title end)"']],
              action = function()
                vim.ui.open("https://github.com/notifications")
              end,
              key = "n",
              icon = " ",
              height = 5,
              enabled = true,
            },
            {
              title = "Open Issues",
              cmd = "gh issue list -L 3",
              key = "i",
              action = function()
                vim.fn.jobstart("gh issue list --web", { detach = true })
              end,
              icon = " ",
              height = 7,
            },
            {
              icon = " ",
              title = "Open PRs",
              cmd = "gh pr list -L 3",
              key = "P",
              action = function()
                vim.fn.jobstart("gh pr list --web", { detach = true })
              end,
              height = 7,
            },
            {
              icon = " ",
              title = "Git Status",
              cmd = "git --no-pager diff --stat -B -M -C",
              height = 10,
            },
          }
          return vim.tbl_map(function(cmd)
            return vim.tbl_extend("force", {
              pane = 2,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            }, cmd)
          end, cmds)
        end,

        -- Pane 3: Files & System
        {
          pane = 3,
          section = "terminal",
          cmd = "colorscript -e square",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
          enabled = function()
            return vim.fn.executable("colorscript") == 1
          end,
        },
        { pane = 3, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 3, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 3,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
      },
    },

    -- Dim: Focus on the active code scope by dimming surrounding code
    dim = {
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
      animate = {
        enabled = vim.fn.has("nvim-0.10") == 1,
        easing = "outQuad",
        duration = {
          step = 20,
          total = 300,
        },
      },
      filter = function(buf)
        return vim.g.snacks_dim ~= false and vim.b[buf].snacks_dim ~= false and vim.bo[buf].buftype == ""
      end,
    },
  },
  keys = {
    {
      "<leader>td",
      function()
        Snacks.toggle.dim():toggle()
      end,
      desc = "Toggle Scope Dimming",
    },
  },
}

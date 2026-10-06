return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Completion engine capabilities bridge
      "saghen/blink.cmp",
    },
    config = function()
      -- Define servers to setup (using system executables)
      local servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
          },
        },
        perlnavigator = {},
      }

      -- Get completion capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- 1. Setup and enable each server using native Neovim 0.11+ API
      for server_name, server_opts in pairs(servers) do
        local config = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, server_opts)
        vim.lsp.config(server_name, config)
        vim.lsp.enable(server_name)
      end

      -- 2. Diagnostics appearance (clean, no intrusive inline virtual text)
      vim.diagnostic.config({
        virtual_text = false, -- keep code lines clean; view errors in float/status
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✗",
            [vim.diagnostic.severity.WARN]  = "▲",
            [vim.diagnostic.severity.HINT]  = "●",
            [vim.diagnostic.severity.INFO]  = "ℹ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "always",
        },
      })

      -- 3. Buffer-local keymaps attached when LSP connects to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Navigation
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gr", vim.lsp.buf.references, "Find References")
          map("gI", vim.lsp.buf.implementation, "Go to Implementation")
          map("gy", vim.lsp.buf.type_definition, "Type Definition")

          -- Hover / Docs
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          -- Refactoring & Actions
          map("<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

          -- Diagnostics jumping
          map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous Diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next Diagnostic")
          map("<leader>e", vim.diagnostic.open_float, "Show Diagnostic Popup")

          -- C/C++ specific: Switch between source and header
          if vim.bo[event.buf].filetype == "c" or vim.bo[event.buf].filetype == "cpp" then
            map("<leader>a", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source/Header")
          end
        end,
      })
    end,
  },
}

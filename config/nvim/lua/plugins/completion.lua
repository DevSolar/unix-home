return {
  "saghen/blink.cmp",
  -- Provides rich pre-built snippets for common languages
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  -- Use release version with pre-compiled fuzzy search binary
  version = "*",
  opts = {
    -- Keymap presets:
    -- 'default': <C-space> open, <C-y> accept, <C-p>/<C-n> navigate
    -- 'super-tab': <Tab> / <S-Tab> navigate/accept, <Enter> accept
    keymap = {
      preset = "super-tab",
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    -- Completion sources: LSP, path suggestions, snippets, buffer words
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    -- Documentation and signature popups
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "rounded" },
      },
      menu = {
        border = "rounded",
      },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
  },
}

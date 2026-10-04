return {
  "nvim-treesitter/nvim-treesitter",
  -- On Neovim 0.12+ (nightly/head), nvim-treesitter uses the 'main' branch rewrite.
  lazy = false,
  build = ":TSUpdate",
  opts = {
    ensure_installed = {
      "c",
      "cpp",
      "c_sharp",
      "lua",
      "vim",
      "vimdoc",
      "markdown",
      "markdown_inline",
      "make",
      "xml",
      "bash",
      "perl"
    },
  },
  config = function(_, opts)
    require("nvim-treesitter").setup(opts)
    if opts.ensure_installed then
      require("nvim-treesitter").install(opts.ensure_installed)
    end
  end,
}

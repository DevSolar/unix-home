-- Indentation
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Whitespace & display
vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = ".", nbsp = "@", extends = "#" }
vim.opt.fillchars:append({ diff = "░" })
vim.opt.scrolloff = 3
vim.opt.showmatch = true
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Mouse & Clipboard
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- Spelling
vim.opt.spelllang = { "de" }

-- Colorscheme
vim.cmd.colorscheme("dimopinions")

-- CamelCase navigation
local cc_pattern = [[\<\<Bar>\U\@<=\u\<Bar>\u\ze\%(\U\&\>\@!\)\<Bar>\%]]
vim.keymap.set("n", "<C-h>", function() vim.fn.search(cc_pattern .. "^", "bW") end, { silent = true, desc = "Prev CamelCase segment" })
vim.keymap.set("n", "<C-l>", function() vim.fn.search(cc_pattern .. "$", "W") end, { silent = true, desc = "Next CamelCase segment" })
vim.keymap.set("i", "<C-h>", function() vim.fn.search(cc_pattern .. "^", "bW") end, { silent = true, desc = "Prev CamelCase segment" })
vim.keymap.set("i", "<C-l>", function() vim.fn.search(cc_pattern .. "$", "W") end, { silent = true, desc = "Next CamelCase segment" })


-- Plugins
require("config.lazy")

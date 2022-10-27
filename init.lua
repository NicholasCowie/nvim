require "plugins"
require "keymaps"
require "mylsp"
require "mycmp"
require "mytrees"
require "latex-scope"
require "bib-collect"

-- Settings
vim.cmd[[colorscheme tokyonight]]
vim.wo.number = true -- which line in the gutter
vim.wo.relativenumber = true -- show relative numbers
vim.o.mouse = "a" -- Enable your mouse
vim.g.noswapfile = true -- swap file is annoying
vim.wo.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
vim.bo.smartindent = true -- Makes indenting smart
vim.cmd[[au TextYankPost * silent! lua vim.highlight.on_yank()]] -- highlight yanked
-- infinite, persistent undo
vim.cmd([[
  set undodir =~/.vim/vimdid
  set undofile
]])

-- python
require("lspconfig").pylsp.setup({
  cmd = {"pyls"},
  filetypes = { "python" },
})

-- latex
require("lspconfig").texlab.setup({
  cmd = { "texlab" },
  filetypes = { "plaintex", "tex", "bib" },
  settings = {
    texlab = {
      build = {
        onSave = true;
      },
      forwardSearch = {
        -- this should be your PDF viewer executable
        executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
        args = {"%l", "%p", "%f", "-g"},
        onSave = true;
      }
    }
  }
})

-- docker
require("lspconfig").dockerls.setup({
	cmd = { "docker-langserver", "--stdio" },
	root_dir = vim.loop.cwd,
})

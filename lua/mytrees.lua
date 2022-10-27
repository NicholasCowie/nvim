require("nvim-treesitter.configs").setup{
     highlight = { enable = true, -- false will disable the whole extension
  },
  -- indent = {enable = true, disable = {"python", "html", "javascript"}},
  -- TODO seems to be broken
  indent = { disable = { "python" } },
  autotag = { enable = true },
  -- nvim-treesitter-textobjects motions
  textobjects = {
     select = {
        enable = true,
  
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
  
        keymaps = {
           -- You can use the capture groups defined in textobjects.scm
           ["ac"] = "@class.outer",
           ["ic"] = "@class.inner",
           ["ab"] = "@block.outer",
           ["ib"] = "@block.inner",
        },
  
     },
     move = {
        set_jumps = false,
        -- move to next function!
        goto_next_start = {
           ["]]"] = "@function.outer",
        },
        goto_previous_start = {
           ["[["] = "@function.outer",
        },
     }
  }
}

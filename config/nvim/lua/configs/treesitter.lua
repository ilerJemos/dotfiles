require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers for common languages
require("nvim-treesitter").install({
  "lua", "vim", "vimdoc", "query",
  "javascript", "typescript", "tsx",
  "html", "css", "json", "yaml", "toml",
  "python", "go", "rust", "c", "cpp",
  "bash", "markdown", "markdown_inline",
})

-- Enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Enable treesitter-based folding
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    pcall(function()
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo[0][0].foldmethod = "expr"
    end)
  end,
})

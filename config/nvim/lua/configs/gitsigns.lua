require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false,
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol",
    delay = 1000,
    ignore_whitespace = false,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
    vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })
    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
    vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
  end,
})

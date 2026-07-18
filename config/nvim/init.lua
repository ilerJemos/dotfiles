-- Enable Neovim UI2
require("vim._core.ui2").enable({})

-- Native package management (vim.pack)
-- Plugins are installed automatically on first launch
vim.pack.add({
  -- Fuzzy finder
  "https://github.com/ibhagwan/fzf-lua",

  -- File explorer dependencies
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",

  -- File explorer
  "https://github.com/nvim-neo-tree/neo-tree.nvim",

  -- Colorscheme
  "https://github.com/folke/tokyonight.nvim",

  -- Statusline
  "https://github.com/nvim-lualine/lualine.nvim",

  -- Treesitter (syntax highlighting)
  "https://github.com/nvim-treesitter/nvim-treesitter",

  -- Git signs
  "https://github.com/lewis6991/gitsigns.nvim",

  -- Auto pairs
  "https://github.com/windwp/nvim-autopairs",

  -- Comment
  "https://github.com/numToStr/Comment.nvim",

  -- Indent guides
  "https://github.com/lukas-reineke/indent-blankline.nvim",

  -- LSP
  -- "https://github.com/neovim/nvim-lspconfig",

  -- Autocompletion
  -- "https://github.com/hrsh7th/nvim-cmp",
  -- "https://github.com/hrsh7th/cmp-nvim-lsp",
  -- "https://github.com/hrsh7th/cmp-buffer",
})

-- Load options
require("options")

-- Plugin configurations
require("configs.tokyonight")
require("configs.treesitter")
require("configs.lualine")
require("configs.neo-tree")
require("configs.gitsigns")
require("configs.autopairs")
require("configs.comment")
require("configs.indent-blankline")

-- Plugin keybindings
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help tags" })
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File explorer" })

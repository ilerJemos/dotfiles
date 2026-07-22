-- config/nvim/lua/configs/tokyonight.lua - 配色主题
require("tokyonight").setup({
  style = "storm",        -- 风格：storm / moon / night / day
  transparent = false,    -- 不透明背景（true 则透出终端背景）
  terminal_colors = true, -- 用主题色覆盖终端 16 色
})

vim.cmd.colorscheme("tokyonight") -- 应用主题

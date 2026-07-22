-- config/nvim/lua/configs/indent-blankline.lua - 缩进对齐竖线
require("ibl").setup({
  indent = {
    char = "│",        -- 缩进竖线字符
    tab_char = "│",    -- Tab 处也用同款竖线
  },
  scope = {
    enabled = true,    -- 高亮当前作用域层级（突出所在块）
    show_start = true, -- 在作用域起始行下划线
    show_end = false,  -- 不在结束行下划线（避免过密）
  },
  exclude = {
    filetypes = {      -- 这些类型不显示缩进线
      "help",
      "neo-tree",
      "mason",
    },
  },
})

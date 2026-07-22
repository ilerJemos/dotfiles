-- config/nvim/lua/configs/treesitter.lua - 语法解析器安装与高亮启用
require("nvim-treesitter").setup({
  install_dir = vim.fn.stdpath("data") .. "/site", -- 解析器装到 nvim 数据目录下的 site
})

-- 为常用语言安装解析器（首次启动自动拉取/编译）
require("nvim-treesitter").install({
  "lua", "vim", "vimdoc", "query",                              -- nvim 自身相关
  "javascript", "typescript", "tsx",                            -- 前端
  "html", "css", "json", "yaml", "toml",                        -- 配置/标记
  "python", "go", "rust", "c", "cpp",                           -- 后端/系统语言
  "bash", "markdown", "markdown_inline",                        -- 脚本与文档
})

-- 为所有文件类型启用 treesitter 高亮（pcall 容错：无解析器时静默跳过）
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",                       -- 匹配所有文件类型
  callback = function()
    pcall(vim.treesitter.start)        -- 启动 treesitter 高亮（失败不报错）
  end,
})

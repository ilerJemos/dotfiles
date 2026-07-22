-- config/nvim/lua/configs/lsp.lua - LSP 诊断显示 + 启用语言服务器
-- Neovim 0.11+ 自带 LSP 客户端 vim.lsp，配置由 nvim-lspconfig 提供默认值。

-- 诊断显示
vim.diagnostic.config({
  virtual_text = true,         -- 行尾内联显示错误文本
  signs = true,                -- 标志列显示诊断符号
  underline = true,            -- 出错文本下划线
  update_in_insert = false,    -- 插入模式时不实时更新诊断（避免输入卡顿）
  severity_sort = true,        -- 按严重性排序（Error 优先）
  float = { border = "rounded", source = "if_many" }, -- 浮窗圆角边框，多来源时显示来源
})

-- 启用语言服务器（默认配置来自 nvim-lspconfig）。
-- 二进制由 mason 自动安装（见 configs/mason-lspconfig.lua）。
-- 覆盖某服务器示例：
--   vim.lsp.config("gopls", { settings = { gopls = { staticcheck = true } } })
vim.lsp.enable({ "clangd", "pyright", "gopls" }) -- C/C++、Python、Go

-- 诊断快捷键（Neovim 默认浮窗是 <C-W>d）
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" }) -- 当前行诊断浮窗
vim.keymap.set("n", "<leader>cl", vim.diagnostic.setloclist, { desc = "Diagnostic list" }) -- 诊断列表到 location list

-- Neovim 0.11+ 在 LSP 附着时自动提供默认按键（无需手动 on_attach 重定义）：
--   K          hover（悬停文档）
--   gd gD gi   跳转定义 / 声明 / 实现
--   grn        rename（重命名符号）
--   gra        code action（代码操作）
--   grr        references（引用）
--   gri        implementation（实现）
--   gO         document symbols（文档符号）
--   [d  ]d     上 / 下一条诊断

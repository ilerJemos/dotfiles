-- config/nvim/lua/configs/mason-lspconfig.lua - mason 与 lspconfig 桥接
-- ensure_installed 会在首次启动时自动安装这些语言服务器；
-- automatic_enable（默认 true）会对已安装的服务器执行 vim.lsp.enable()。
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright", "gopls" }, -- C/C++、Python、Go 的 LSP
})

-- config/nvim/init.lua - Neovim 入口：启用 UI2、声明插件、加载配置、注册按键
-- 用 Neovim 0.12+ 原生 vim.pack 管理插件（无需 lazy.nvim / packer 等外部管理器）。

-- 启用 Neovim UI2（vim._core.ui2，0.12+ 的实验性内部 API；
-- 跨版本可能变动或移除，故用 pcall 尽力启用，失败则静默忽略）。
pcall(function()
  require("vim._core.ui2").enable({})
end)

-- 原生包管理（vim.pack）：首次启动自动克隆/拉取下列插件到本地。
vim.pack.add({
  "https://github.com/ibhagwan/fzf-lua",            -- 模糊查找器（文件/grep/git 等）

  "https://github.com/nvim-lua/plenary.nvim",       -- neo-tree 依赖的通用 Lua 工具库
  "https://github.com/MunifTanjim/nui.nvim",        -- neo-tree 依赖的 UI 组件库

  "https://github.com/nvim-neo-tree/neo-tree.nvim", -- 文件浏览器侧栏

  "https://github.com/folke/tokyonight.nvim",       -- 配色主题

  "https://github.com/nvim-lualine/lualine.nvim",   -- 底部状态栏

  "https://github.com/nvim-treesitter/nvim-treesitter", -- Treesitter 增量语法解析（高亮/折叠）

  "https://github.com/lewis6991/gitsigns.nvim",     -- 标志列显示 git 改动 + hunk 操作

  "https://github.com/windwp/nvim-autopairs",       -- 自动配对括号/引号

  -- 注释切换：基于 treesitter 推断 commentstring，配合 Neovim 内置 gc/gcc 操作符
  "https://github.com/folke/ts-comments.nvim",

  "https://github.com/lukas-reineke/indent-blankline.nvim", -- 缩进对齐竖线

  "https://github.com/folke/which-key.nvim",        -- 按键提示弹窗（按键序列可视化）

  "https://github.com/neovim/nvim-lspconfig",       -- LSP 服务器默认配置
  "https://github.com/mason-org/mason.nvim",        -- LSP/DAP/linter/formatter 安装管理
  "https://github.com/mason-org/mason-lspconfig.nvim", -- mason 与 lspconfig 桥接

  -- 补全：blink.cmp（锁定 v1 主线），friendly-snippets 提供代码片段
  { src = "https://github.com/saghen/blink.cmp", version = "v1" },
  "https://github.com/rafamadriz/friendly-snippets",
})

-- 加载通用选项（见 lua/options.lua）
require("options")

-- 逐个加载插件配置；用 pcall 包裹，单个插件失败不影响整体启动。
for _, name in ipairs({
  "tokyonight", "treesitter", "lualine", "neo-tree",
  "gitsigns", "autopairs", "ts-comments", "indent-blankline", "which-key",
  "mason", "mason-lspconfig", "lsp", "blink",
}) do
  local ok, err = pcall(require, "configs." .. name) -- 加载 lua/configs/<name>.lua
  if not ok then
    vim.notify("Failed to load configs." .. name .. ": " .. tostring(err), vim.log.levels.ERROR) -- 启动时报错提示
  end
end

-- fzf-lua 查找按键
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })     -- 查找文件
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })  -- 实时 grep
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })       -- 切换缓冲区
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "Help tags" })   -- 查找帮助
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "File explorer" })  -- 开关文件树

-- git 相关（经 fzf-lua）
vim.keymap.set("n", "<leader>gs", "<cmd>FzfLua git_status<cr>", { desc = "Git status" })   -- git status
vim.keymap.set("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>", { desc = "Git commits" }) -- 提交历史
vim.keymap.set("n", "<leader>gB", "<cmd>FzfLua git_branches<cr>", { desc = "Git branches" })-- 分支列表
vim.keymap.set("n", "<leader>gf", "<cmd>FzfLua git_files<cr>", { desc = "Git files" })     -- git 跟踪文件

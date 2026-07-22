-- config/nvim/lua/options.lua - Neovim 选项与基础按键映射
-- 每个选项都附注释，便于很久以后回顾其作用与取舍。

-- <leader> / <localleader>：用空格作前缀键，按键方便且与多数插件约定一致。
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 禁用内置 netrw 文件浏览器，改用 neo-tree（避免两者并存抢快捷键/缓冲区）。
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.nu = true            -- 显示绝对行号
vim.opt.relativenumber = true -- 相对行号：上下移动 (j/k 配合 5j 等) 更直观

vim.opt.tabstop = 2          -- Tab 在文件中占 2 个空格宽
vim.opt.shiftwidth = 2       -- 自动缩进每级 2 个空格
vim.opt.expandtab = true     -- 把 Tab 展开为空格（避免混用 Tab/空格）
vim.opt.smartindent = true   -- 智能缩进：根据语法自动调整新行缩进

vim.opt.wrap = false         -- 长行不自动折行（横向滚动，代码更易读）

vim.opt.foldenable = false   -- 默认关闭折叠（避免打开文件时大段代码被折叠）

vim.opt.swapfile = false     -- 不生成 .swp 交换文件
vim.opt.backup = false       -- 不生成 ~ 备份文件
vim.opt.undofile = true      -- 持久化撤销历史到磁盘，关闭文件后仍可撤销

vim.opt.hlsearch = true      -- 高亮搜索匹配
vim.opt.incsearch = true     -- 输入搜索词时即时跳转匹配

vim.opt.termguicolors = true -- 启用 24-bit 真彩色（插件主题需要）

vim.opt.scrolloff = 8        -- 光标距屏幕顶/底至少留 8 行上下文
vim.opt.signcolumn = "yes"   -- 始终显示标志列（避免 LSP/git 符号导致文本抖动）
vim.opt.isfname:append("@-@") -- 把 @-@ 视为文件名合法字符（某些路径需要）

vim.opt.updatetime = 50      -- 触发 CursorHold / 写 swap 的事件间隔（ms），影响 LSP 诊断刷新

vim.opt.clipboard = "unnamedplus" -- 系统剪贴板（需要 xclip / wl-clipboard）
vim.opt.mouse = "a"          -- 所有模式启用鼠标
vim.opt.splitright = true    -- 新垂直窗口开在右侧
vim.opt.splitbelow = true    -- 新水平窗口开在下方
vim.opt.timeoutlen = 400     -- 影响 <leader> 超时与 which-key 弹窗延迟（ms）
vim.opt.completeopt = "menu,menuone,noselect" -- 补全菜单行为：弹菜单、仅一项也弹、不预选
vim.opt.ignorecase = true    -- 搜索忽略大小写
vim.opt.smartcase = true     -- 但搜索词含大写字母时恢复大小写敏感
vim.opt.inccommand = "split" -- :s 替换实时预览（在分隔窗口中展示）

-- 基础按键映射
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })            -- 保存文件
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })            -- 退出
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" }) -- 清除搜索高亮
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })     -- 跳到左侧窗口
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })    -- 跳到下方窗口
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })    -- 跳到上方窗口
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })    -- 跳到右侧窗口

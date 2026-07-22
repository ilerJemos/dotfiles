-- config/nvim/lua/configs/neo-tree.lua - 文件浏览器侧栏
require("neo-tree").setup({
  close_if_last_window = true,    -- 关掉最后一个文件时，neo-tree 是唯一窗口则一并关闭
  popup_border_style = "rounded", -- 弹窗圆角
  enable_git_status = true,       -- 显示文件 git 状态
  enable_diagnostics = true,      -- 显示 LSP 诊断
  filesystem = {
    follow_current_file = {
      enabled = true,             -- 光标切换文件时，文件树跟随定位
    },
    use_libuv_file_watcher = true, -- 用 libuv 监听文件变化（外部改动实时刷新）
    filtered_items = {
      visible = false,            -- 默认隐藏被过滤项
      hide_dotfiles = false,      -- 不隐藏点文件（.git 等）
      hide_gitignored = false,    -- 不隐藏 gitignore 的文件
    },
  },
  window = {
    position = "left",            -- 侧栏在左
    width = 30,                   -- 列宽 30
    mappings = {
      ["<space>"] = "none",       -- 屏蔽空格（避免与 <leader> 冲突）
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true,      -- 显示展开/折叠箭头
    },
    git_status = {
      symbols = {                 -- git 状态符号（纯 Unicode，无 Nerd Font）
        added = "✚",              -- 新增
        modified = "•",           -- 修改
        deleted = "✖",            -- 删除
        renamed = "➜",            -- 重命名
        untracked = "?",          -- 未跟踪
        ignored = "◌",            -- 已忽略
        unstaged = "○",           -- 未暂存
        staged = "✚",             -- 已暂存
        conflict = "",           -- 冲突
      },
    },
  },
})

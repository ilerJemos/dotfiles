-- config/nvim/lua/configs/blink.cmp.lua - 补全引擎配置（blink.cmp v1）
require("blink.cmp").setup({
  -- 按键方案 'default'：C-y 确认、C-space 触发、C-n/C-p 上下选择。
  -- 备选：'super-tab'（Tab 确认）、'enter'（Enter 确认）。
  keymap = { preset = "default" },
  -- 默认补全来源：LSP > 路径 > 代码片段 > 当前缓冲区
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = {
    -- 选中候选项时自动弹出文档，延迟 200ms
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
  },
  -- 优先用 Rust 预编译模糊匹配（快），无二进制/cargo 时静默回退到 Lua 实现
  fuzzy = { implementation = "prefer_rust" },
  signature = { enabled = true }, -- 输入函数参数时显示签名帮助
})

-- config/nvim/lua/configs/lualine.lua - 底部状态栏
require("lualine").setup({
  options = {
    theme = "tokyonight",                              -- 配色与编辑区一致
    component_separators = { left = "", right = "" },  -- 段间无分隔符（简洁）
    section_separators = { left = "", right = "" },    -- 段间无箭头分隔
    globalstatus = true,                               -- 全局单状态栏（窗口切换不抖动）
  },
  sections = {
    lualine_a = { "mode" },                            -- 当前模式（NORMAL/INSERT…）
    lualine_b = { "branch", "diff", "diagnostics" },   -- 分支 / 改动统计 / 诊断计数
    lualine_c = { "filename" },                        -- 文件名
    lualine_x = { "encoding", "fileformat", "filetype" }, -- 编码 / 换行格式 / 文件类型
    lualine_y = { "progress" },                        -- 文件内位置百分比
    lualine_z = { "location" },                        -- 光标行列
  },
})

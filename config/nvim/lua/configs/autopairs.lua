-- config/nvim/lua/configs/autopairs.lua - 自动配对括号/引号配置
require("nvim-autopairs").setup({
  check_ts = true,            -- 用 treesitter 判断上下文，避免在字符串/注释里误配对
  ts_config = {
    lua = { "string", "source" },        -- lua：在 string/source 节点内不配对
    javascript = { "string", "template_string" }, -- js：含模板字符串内不配对
    java = false,                        -- java：不启用 ts 检查
  },
  fast_wrap = {               -- 快速包裹：在括号外按 <M-e>（Alt+e）把选区包进括号
    map = "<M-e>",            -- 触发键
    chars = { "{", "[", "(", '"', "'" }, -- 可包裹的字符
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""), -- 定位结束位置的匹配模式
    offset = 0,               -- 光标偏移
    end_key = "$",            -- 确认键
    keys = "qwertyuiopzxcvbnmasdfghjkl", -- 标记目标位置用的字母
    check_comma = true,       -- 是否考虑逗号后的空格
    highlight = "PmenuSel",   -- 标记高亮组
    highlight_grey = "LineNr", -- 其余位置灰色高亮组
  },
})

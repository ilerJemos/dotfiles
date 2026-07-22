-- config/nvim/lua/configs/gitsigns.lua - git 标志列 + hunk 操作
require("gitsigns").setup({
  signs = {                      -- 标志列各状态对应的符号（竖线风格，无需 Nerd Font）
    add = { text = "│" },        -- 新增行
    change = { text = "│" },     -- 修改行
    delete = { text = "_" },     -- 删除行（下方有内容）
    topdelete = { text = "‾" },  -- 顶部删除
    changedelete = { text = "~" }, -- 修改且删除
    untracked = { text = "┆" },  -- 未跟踪
  },
  signcolumn = true,             -- 在标志列显示
  numhl = false,                 -- 不用数字行额外高亮（避免干扰）
  linehl = false,                -- 不整行高亮（避免干扰）
  word_diff = false,             -- 不启用单词级 diff
  watch_gitdir = {
    follow_files = true,         -- git 索引变化时跟随重命名的文件
  },
  attach_to_untracked = true,    -- 对未跟踪文件也附加 gitsigns
  current_line_blame = false,    -- 不显示当前行的 blame（按需用 <leader>gb 查）
  on_attach = function(bufnr)    -- 进入缓冲区时注册以下按键（仅对该 buffer 生效）
    local gs = require("gitsigns")

    -- hunk 跳转（nav_hunk 取代已废弃的 next_hunk/prev_hunk）
    vim.keymap.set("n", "]h", function() gs.nav_hunk("next") end, { buffer = bufnr, desc = "Next hunk" }) -- 下一个改动块
    vim.keymap.set("n", "[h", function() gs.nav_hunk("prev") end, { buffer = bufnr, desc = "Prev hunk" }) -- 上一个改动块

    -- 暂存/撤销（visual 模式作用于选中行）
    vim.keymap.set("n", "<leader>ga", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" }) -- 暂存当前 hunk
    vim.keymap.set("x", "<leader>ga", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Stage hunk" }) -- 暂存选中行
    vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { buffer = bufnr, desc = "Reset hunk" }) -- 还原当前 hunk
    vim.keymap.set("x", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { buffer = bufnr, desc = "Reset hunk" }) -- 还原选中行
    vim.keymap.set("n", "<leader>gA", gs.stage_buffer, { buffer = bufnr, desc = "Stage buffer" }) -- 暂存整个 buffer
    vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr, desc = "Reset buffer" }) -- 还原整个 buffer
    vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage" }) -- 撤销暂存

    -- 查看
    vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" }) -- 预览当前 hunk diff
    vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" }) -- 当前行 blame
    vim.keymap.set("n", "<leader>gd", gs.diffthis, { buffer = bufnr, desc = "Diff buffer" }) -- 打开 diff 视图

    -- hunk 文本对象：如 vih 选中、dih 删除
    vim.keymap.set({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", { buffer = bufnr, desc = "Select hunk" })
  end,
})

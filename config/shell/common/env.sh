# common/env.sh - 通用环境变量（POSIX 兼容，bash/zsh 共用）

# 默认编辑器：优先 nvim，回退 vim/vi
if command -v nvim >/dev/null 2>&1; then
    EDITOR=nvim                           # 有 nvim 则用 nvim
elif command -v vim >/dev/null 2>&1; then
    EDITOR=vim                            # 否则 vim
else
    EDITOR=vi                             # 兜底 vi
fi
export EDITOR                             # 导出，供 git/crontab 等读取
export VISUAL="$EDITOR"                   # VISUAL 同 EDITOR（部分程序优先读 VISUAL）

# 分页器
export PAGER=less                         # 默认用 less 分页
export LESS='-FRX'      # F 短输出直接输出; R 保留颜色; X 退出不清屏

# 语言/区域（统一 UTF-8）
export LANG=en_US.UTF-8                   # 避免 POSIX/C 区域下的中文乱码

# XDG 基础目录默认值（仅当未预设时填充）
: "${XDG_CONFIG_HOME:=$HOME/.config}"     # 配置目录
: "${XDG_DATA_HOME:=$HOME/.local/share}"  # 数据目录
: "${XDG_CACHE_HOME:=$HOME/.cache}"       # 缓存目录
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME  # 导出供后续脚本使用

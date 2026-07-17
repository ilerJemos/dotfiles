# common/env.sh - 通用环境变量（POSIX 兼容，bash/zsh 共用）

# 默认编辑器：优先 nvim，回退 vim/vi
if command -v nvim >/dev/null 2>&1; then
    EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
    EDITOR=vim
else
    EDITOR=vi
fi
export EDITOR
export VISUAL="$EDITOR"

# 分页器
export PAGER=less
export LESS='-FRX'      # F 短输出直接输出; R 保留颜色; X 退出不清屏

# 语言/区域（统一 UTF-8）
export LANG=en_US.UTF-8

# XDG 基础目录默认值
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_CACHE_HOME

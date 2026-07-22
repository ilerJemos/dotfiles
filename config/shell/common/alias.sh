# common/alias.sh - 常用别名（POSIX 兼容，bash/zsh 共用）
# 每行附注释，便于很久以后回顾。

# ls / 列目录：优先 eza（现代化替代，带 git 状态），否则回退 GNU/BSD ls
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'                       # ls 用 eza
    alias ll='eza -lh --git'             # 长格式 + 文件大小 + git 状态
    alias la='eza -lah --git'            # 长格式 + 含隐藏文件
    alias l='eza'                        # 简短列出
    alias tree='eza --tree --level=2'    # 树状视图（2 层）
else
    # GNU ls 支持 --color；用 --version 探测（无参 ls 会列目录）
    if ls --version >/dev/null 2>&1; then
        alias ls='ls --color=auto'       # GNU ls 自动着色
    else
        alias ls='ls -G'                 # BSD ls 用 -G 着色
    fi
    alias ll='ls -lh'                    # 长格式
    alias la='ls -lah'                   # 长格式 + 隐藏文件
    alias l='ls -CF'                     # 分列短格式
fi

# 导航
alias ..='cd ..'                         # 上一级目录
alias ...='cd ../..'                     # 上两级
alias ....='cd ../../..'                 # 上三级
alias -- -='cd -'                        # 回到上一个目录（- 需 -- 终止选项解析）

# 安全/便利
alias cp='cp -i'                         # 复制前确认覆盖
alias mv='mv -i'                         # 移动前确认覆盖
alias rm='rm -i'                         # 删除前确认（防误删）
alias mkdir='mkdir -p'                   # 自动创建父目录
alias df='df -h'                         # 磁盘用量人类可读
alias du='du -h'                         # 目录大小人类可读

# grep 着色
alias grep='grep --color=auto'           # grep 匹配项着色
alias egrep='egrep --color=auto'         # 扩展正则着色
alias fgrep='fgrep --color=auto'         # 固定字符串着色

# 快捷
alias h='history'                        # 查看历史
alias c='clear'                          # 清屏
alias path='echo $PATH | tr ":" "\n"'    # 每行打印一个 PATH 条目
alias reload='exec "$SHELL"'             # 重载 shell（exec 替换当前进程）

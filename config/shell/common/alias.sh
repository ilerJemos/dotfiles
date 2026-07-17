# common/alias.sh - 常用别名（POSIX 兼容，bash/zsh 共用）

# ls / 列目录：优先 eza，否则 GNU(--color)/BSD(-G)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -lh --git'
    alias la='eza -lah --git'
    alias l='eza'
    alias tree='eza --tree --level=2'
else
    if ls --color=auto >/dev/null 2>&1; then
        alias ls='ls --color=auto'
    else
        alias ls='ls -G'
    fi
    alias ll='ls -lh'
    alias la='ls -lah'
    alias l='ls -CF'
fi

# 导航
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# 安全/便利
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'

# grep 着色
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# 快捷
alias h='history'
alias c='clear'
alias path='echo $PATH | tr ":" "\n"'
alias reload='exec "$SHELL"'

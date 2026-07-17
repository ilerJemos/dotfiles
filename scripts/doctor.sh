#!/bin/sh
# scripts/doctor.sh - 环境健康检查
set -u

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
pass=0 fail=0

ok() { printf '  ✓ %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  ✗ %s\n' "$1"; fail=$((fail+1)); }

check() { name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else no "$name"; fi; }
check_link() {
    dest=$1 want=$2
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$REPO/$want" ]; then
        ok "$dest"
    else
        no "$dest (未链接/指向错误)"
    fi
}

echo "== 工具 =="
check git      command -v git
check zsh      command -v zsh
check tmux     command -v tmux
check nvim     command -v nvim
check starship command -v starship
check rg       command -v rg
check fd       command -v fd
check fzf      command -v fzf
check bat      command -v bat
check eza      command -v eza

echo "== 链接 =="
check_link "$HOME/.config/shell" config/shell
check_link "$HOME/.zshrc"        home/.zshrc
check_link "$HOME/.bashrc"       home/.bashrc
check_link "$HOME/.gitconfig"    gitconfig

echo "== 补全 =="
check "zsh compinit" zsh -c 'autoload -Uz compinit && typeset -f compinit >/dev/null'
[ -f "$HOME/.config/shell/zsh/completion.zsh" ]   && ok "zsh/completion.zsh"   || no "zsh/completion.zsh (未部署？运行 ./install.sh)"
[ -f "$HOME/.config/shell/bash/completion.bash" ] && ok "bash/completion.bash" || no "bash/completion.bash (未部署？运行 ./install.sh)"

echo ""
echo "通过 $pass / 失败 $fail"
[ "$fail" = 0 ] || exit 1

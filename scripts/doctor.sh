#!/bin/sh
# scripts/doctor.sh - 环境健康检查
# 校验工具、nvim 版本、配置可加载性、符号链接、补全等是否就绪。
set -u                           # -u 引用未定义变量即报错（不用 -e：单项失败应继续检查）

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录
pass=0 fail=0                    # 通过/失败计数

ok() { printf '  ✓ %s\n' "$1"; pass=$((pass+1)); }  # 记录通过
no() { printf '  ✗ %s\n' "$1"; fail=$((fail+1)); }  # 记录失败

check() { name=$1; shift; if "$@" >/dev/null 2>&1; then ok "$name"; else no "$name"; fi; }  # 跑命令，按退出码判定
check_link() {
    dest=$1 want=$2
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$REPO/$want" ]; then  # 是链接且指向仓库内目标
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

# fzf >= 0.48 才支持 `fzf --zsh`/`--bash`（shell 集成用）
if command -v fzf >/dev/null 2>&1; then
    fv=$(fzf --version 2>/dev/null | awk '{print $1}')          # 取版本号（如 0.55.0）
    fnum=$(printf '%s' "$fv" | awk -F. '{print $1*100+$2}')     # 转成 主版本*100+次版本 数值
    if [ "${fnum:-0}" -ge 48 ]; then
        ok "fzf 版本 $fv (>=0.48，支持 --zsh/--bash)"
    else
        no "fzf 版本 $fv (<0.48，--zsh/--bash 不可用)"
    fi
else
    no "fzf 版本 (未安装)"
fi

echo "== Neovim =="
v=$(nvim --version 2>/dev/null | head -1 | sed 's/^NVIM v//')  # 提取版本号
case "$v" in
  0.1[2-9].*|0.[2-9].*|[1-9].*) ok "nvim 版本 $v (>=0.12，支持 vim.pack/ui2)" ;;  # 0.12+ 视为达标
  "")                            no "nvim 版本 (nvim 未安装)" ;;
  *)                             no "nvim 版本 $v (<0.12，配置需 0.12+；运行 dotfiles install-nvim 升级)" ;;
esac
check "xclip/wl-copy (系统剪贴板)" sh -c 'command -v xclip || command -v wl-copy'  # nvim 剪贴板需要其一
check "curl (blink.cmp 预编译下载)" command -v curl

echo "== 配置校验 =="
if command -v tmux >/dev/null 2>&1; then
    tmux -L __doctor kill-server 2>/dev/null                    # 清掉同名 socket 的残留 server
    if tmux -L __doctor -f "$REPO/config/tmux/tmux.conf" new-session -d 2>/dev/null; then  # 用隔离 socket 试加载配置
        tmux -L __doctor kill-server 2>/dev/null
        ok "tmux 配置可加载"
    else
        no "tmux 配置加载失败（config/tmux/tmux.conf）"
    fi
else
    no "tmux 配置 (tmux 未安装)"
fi
if command -v starship >/dev/null 2>&1; then
    _serr=$(STARSHIP_CONFIG="$REPO/config/starship.toml" starship print-config 2>&1 1>/dev/null)  # 只取 stderr（错误在此）
    if printf '%s' "$_serr" | grep -qi "ERROR"; then            # stderr 含 ERROR 视为解析失败
        no "starship 配置解析错误（config/starship.toml）"
    else
        ok "starship 配置可解析"
    fi
    unset _serr
else
    no "starship 配置 (starship 未安装)"
fi

echo "== 链接 =="
check_link "$HOME/.config/shell" config/shell  # shell 配置目录
check_link "$HOME/.zshrc"        home/.zshrc
check_link "$HOME/.bashrc"       home/.bashrc
check_link "$HOME/.gitconfig"    gitconfig

echo "== 补全 =="
check "zsh compinit" zsh -c 'autoload -Uz compinit && typeset -f compinit >/dev/null'  # 能否加载 compinit
[ -f "$HOME/.config/shell/zsh/completion.zsh" ]   && ok "zsh/completion.zsh"   || no "zsh/completion.zsh (未部署？运行 ./install.sh)"
[ -f "$HOME/.config/shell/bash/completion.bash" ] && ok "bash/completion.bash" || no "bash/completion.bash (未部署？运行 ./install.sh)"

echo ""
echo "通过 $pass / 失败 $fail"
[ "$fail" = 0 ] || exit 1        # 有失败则退出码 1（便于脚本/CI 判定）

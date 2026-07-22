#!/bin/sh
# scripts/test-home.sh - 在隔离的临时 HOME 中测试 dotfiles（不污染本机）
#
# 原理：把 HOME / XDG_* 指向一个临时目录，执行 install.sh（仅建符号链接，
#       不装包），再启动交互式 shell 加载完整配置。退出后自动清理临时目录。
#       复用本机已装的工具（brew/starship/fzf/zoxide…）做只读验证，不改宿主。
#
# 用法：
#   ./scripts/test-home.sh              # 默认 zsh，退出后清理
#   ./scripts/test-home.sh bash         # 用 bash
#   ./scripts/test-home.sh --keep       # 保留临时目录以便排查
#   ./scripts/test-home.sh bash --keep  # bash + 保留（参数顺序任意）
#
# 能测：link.sh（含备份/幂等）、zshrc/bashrc 加载链、compinit、别名、
#       代理函数（proxy_on/off/status）、平台脚本、starship/fzf/zoxide 接入。
# 注意：
#   - HOME 已重定向，不会覆盖真实 ~/.zshrc、~/.gitconfig 等。
#   - ~/.config/shell 是指向仓库的符号链接，link.sh 创建的空 local.sh 会落到
#     仓库 config/shell/local.sh（已 gitignore，不影响提交；git clean -fdx 可删）。
#   - 不测试 scripts/install.sh 的装包逻辑（brew/apt），那需 Docker/VM。
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录

# --- 解析参数 ---
TEST_SH=zsh                      # 默认测试 shell
KEEP=0                           # 默认退出后清理临时目录
for arg in "$@"; do
    case "$arg" in
        zsh|bash) TEST_SH="$arg" ;;  # 指定测试 shell
        --keep)   KEEP=1 ;;          # 保留临时目录
        *) printf '未知参数：%s\n' "$arg" >&2; exit 2 ;;  # 未知参数报错
    esac
done

# --- 前置检查 ---
[ -x "$REPO/install.sh" ] || { echo "找不到 $REPO/install.sh" >&2; exit 1; }  # 部署入口须存在且可执行
command -v "$TEST_SH" >/dev/null 2>&1 || { echo "未安装 $TEST_SH" >&2; exit 1; }  # 测试 shell 须已安装

# --- 创建临时 HOME ---
T=$(mktemp -d 2>/dev/null || mktemp -d -t dotfiles-test)  # 临时目录（优先 mktemp -d）

# 退出时清理（含异常退出）；--keep 则保留以便排查
cleanup() {
    if [ "$KEEP" = 1 ]; then
        printf '\n==> 保留临时 HOME（--keep）：%s\n' "$T"
    else
        rm -rf "$T"
    fi
}
trap cleanup EXIT                # 任何方式退出都触发 cleanup

# --- 重定向 HOME / XDG（仅影响本脚本进程树，不改宿主环境）---
export HOME="$T"
export XDG_CONFIG_HOME="$T/.config"
export XDG_CACHE_HOME="$T/.cache"      # compinit dump 隔离在此
export XDG_DATA_HOME="$T/.local/share"
unset ZDOTDIR                          # 确保 zsh 读 $HOME/.zshrc，而非宿主 $ZDOTDIR

echo "==> 临时 HOME：$T"
echo "==> 部署符号链接（仅链接，不装包）"
"$REPO/install.sh"              # 在临时 HOME 下建符号链接

echo ""
echo "==> 启动 $TEST_SH（加载测试配置；输入 exit 退出后自动清理）"
echo "    可试：proxy_on / proxy_status / git<Tab> / dotfiles doctor / starship"
echo ""

# 以子进程启动交互 shell（非 exec），退出后回到本脚本触发 trap 清理
"$TEST_SH" -i                   # -i 强制交互模式

echo ""
echo "==> 已退出测试 shell"

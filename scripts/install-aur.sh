#!/bin/sh
# scripts/install-aur.sh - 在 Arch Linux 引导安装 AUR helper（yay）并装 AUR 依赖
#
# 为什么需要：install.sh 的 Arch 分支用 pacman 装官方源包；starship / lazygit /
# yazi / git-delta 仅在 AUR，pacman 装不了。此脚本按 AUR 标准流程克隆 yay 源码、
# `makepkg -si` 装好 yay（已装则跳过），再用它装 aur-packages.txt 里的包。
# 幂等：yay 已存在则直接进 AUR 安装步骤；AUR 包用 --needed 跳过已装。
#
# 与 scripts/install-brew.sh 对称：前者为 macOS 引导 brew，本脚本为 Arch 引导 yay。
# 偏好 paru 的用户可自行装 paru，install.sh 的 AUR 步骤会自动改用 paru。
#
# 用法：sh scripts/install-aur.sh   或   dotfiles install-aur
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录

# 仅在 Arch Linux（pacman）上运行（本仓库仅 Arch 分支用 AUR）
if [ "$(uname -s)" != "Linux" ]; then
    echo "✗ install-aur 仅在 Linux 上运行（当前 $(uname -s)）" >&2
    exit 1
fi
if ! command -v pacman >/dev/null 2>&1; then
    echo "✗ install-aur 仅在 Arch Linux（pacman）上运行" >&2
    exit 1
fi

# makepkg 依赖 base-devel 与 git（应在 pacman-packages.txt 已由 dotfiles install 装好）
command -v git >/dev/null 2>&1     || { echo "✗ 需要 git（先执行 dotfiles install）" >&2; exit 1; }
command -v makepkg >/dev/null 2>&1 || { echo "✗ 需要 base-devel（先执行 dotfiles install）" >&2; exit 1; }

# 从 aur-packages.txt 读取包名（去注释行/空行，剥离行内注释），空格分隔
AUR_PKGS=$(grep -vE '^\s*#|^\s*$' "$REPO/aur-packages.txt" | sed 's/[[:space:]]*#.*//' | tr '\n' ' ')

# --- 1. 引导 yay（已装则跳过）---
if command -v yay >/dev/null 2>&1; then
    echo "==> yay 已安装：$(command -v yay)"
else
    echo "==> 引导安装 yay（AUR helper，源自 AUR 标准流程：克隆 + makepkg -si）"
    YAY_DIR="$HOME/builds/yay"             # 用户级构建目录（makepkg 不能在 root 家目录运行）
    mkdir -p "$(dirname "$YAY_DIR")"       # 确保父目录存在
    if [ -d "$YAY_DIR/.git" ]; then
        echo "  yay 源已存在，拉取最新"
        git -C "$YAY_DIR" pull --ff-only   # 已克隆则快进更新
    else
        git clone --depth 1 https://aur.archlinux.org/yay.git "$YAY_DIR"  # 浅克隆 AUR 仓库
    fi
    # makepkg 不能以 root 运行；-s 自动装构建依赖，-i 装产物，--noconfirm 免交互
    # （-si 调用 sudo pacman 装产物时可能提示 sudo 密码，属正常交互）
    ( cd "$YAY_DIR" && makepkg -si --noconfirm )
fi

# --- 2. 用 yay 装 AUR 包（逐个，单个构建失败不阻断）---
echo "==> 用 yay 安装 AUR 包：$AUR_PKGS"
# yay 以普通用户运行（内部按需 sudo），勿外加 sudo；--needed 跳过已装，--noconfirm 免交互
# 逐个装可隔离构建失败（如缺 rust/go 工具链时仅跳过相关包，不阻断其余）
# shellcheck disable=SC2086
for _ap in $AUR_PKGS; do
    if yay -S --needed --noconfirm "$_ap"; then echo "  ok   $_ap"; else echo "  ⚠ 跳过 $_ap（构建/安装失败，可能缺工具链；亦可改装 *-bin 免编译版）"; fi
done
unset _ap

echo "==> 完成"
yay --version | head -1                   # 打印版本号验证
echo
echo "提示：AUR 包随 yay 日常升级（yay -Syu）。"

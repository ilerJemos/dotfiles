#!/bin/sh
# scripts/install.sh - 按平台安装系统依赖
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错
REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录

# 安装 tpm（tmux 插件管理器），幂等：已存在则跳过
install_tpm() {
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ -d "$TPM_DIR/.git" ]; then
        echo "  tpm 已存在"      # 已克隆则跳过
    else
        echo "  安装 tpm (tmux 插件管理器)"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" || \
            echo "  (tpm 克隆失败，跳过)"  # 离线/无网时不阻断
    fi
}

# 读取包列表：去掉整行注释与空行，并剥离行内注释（"pkg # 说明" -> "pkg"），空格分隔输出。
# 行内注释必须剥离：否则 # 及其后的说明文字会作为参数传给包管理器，导致装包失败。
pkglist() {
    grep -vE '^\s*#|^\s*$' "$1" | sed 's/[[:space:]]*#.*//' | tr '\n' ' '
}

# 逐个安装包列表中的包；单个包不在仓库/安装失败时不阻断后续（容错）。
# 用于 dnf/pacman/AUR：某些包可能不在特定发行版仓库（如 Fedora 官方源可能无 eza/git-delta），
# 逐个安装可跳过缺失项而非整体中止。apt 仍用整体 install（其包列表已对 Ubuntu 26.04+ 校验）。
# $1 = 安装命令前缀（含 sudo 或 yay/paru，如 "sudo dnf install -y"），$2 = 包列表文件
install_pkgs_loop() {
    _icmd=$1; _ifile=$2
    # shellcheck disable=SC2046
    for _ip in $(pkglist "$_ifile"); do
        # shellcheck disable=SC2086
        if $_icmd "$_ip" >/dev/null 2>&1; then echo "  ok   $_ip"; else echo "  skip $_ip（未找到/已装/失败）"; fi
    done
    unset _icmd _ifile _ip
}

case "$(uname -s)" in
    Darwin)                      # macOS
        if command -v brew >/dev/null 2>&1; then
            echo "==> macOS: brew bundle"
            brew bundle --file="$REPO/Brewfile" --no-lock  # 按 Brewfile 安装，--no-lock 不写锁文件
        else
            echo "⚠ 未检测到 Homebrew，请先安装：https://brew.sh"
        fi
        install_tpm              # 装 tpm
        ;;
    Linux)                       # Linux
        if command -v apt-get >/dev/null 2>&1; then
            echo "==> Linux: apt-get install"
            sudo apt-get update  # 刷新包索引
            # 从 apt-packages.txt 读取包名（去注释行/空行，剥离行内注释），传给 apt-get install
            # shellcheck disable=SC2046
            sudo apt-get install -y $(pkglist "$REPO/apt-packages.txt")
        elif command -v dnf >/dev/null 2>&1; then
            echo "==> Linux: dnf install（逐个装，缺失包自动跳过）"
            # 逐个安装：eza/git-delta 等可能不在所有 Fedora 版本官方源，缺失则跳过不中止
            install_pkgs_loop "sudo dnf install -y" "$REPO/dnf-packages.txt"
            # starship / lazygit / yazi 未在 Fedora 官方源，提示按 dnf-packages.txt 注释手动装
            echo "  ℹ starship / lazygit / yazi 未在 Fedora 官方源，见 dnf-packages.txt 注释手动安装"
        elif command -v pacman >/dev/null 2>&1; then
            echo "==> Linux: pacman -S --needed（逐个装，缺失包自动跳过）"
            # 官方源包：--needed 跳过已装（幂等），--noconfirm 免交互；逐个装可跳过缺失项
            install_pkgs_loop "sudo pacman -S --needed --noconfirm" "$REPO/pacman-packages.txt"
            # AUR 包：检测 yay/paru，有则装，无则提示用 install-aur 引导
            AUR_HELPER=
            if command -v yay >/dev/null 2>&1; then
                AUR_HELPER=yay
            elif command -v paru >/dev/null 2>&1; then
                AUR_HELPER=paru
            fi
            if [ -n "$AUR_HELPER" ]; then
                echo "==> Linux (AUR): $AUR_HELPER -S --needed（逐个装，缺失/构建失败自动跳过）"
                # AUR helper 以普通用户运行（内部按需 sudo），勿外加 sudo；逐个装可隔离构建失败
                install_pkgs_loop "$AUR_HELPER -S --needed --noconfirm" "$REPO/aur-packages.txt"
            else
                echo "⚠ 未检测到 AUR helper（yay/paru）；starship/lazygit/yazi/git-delta 未装。"
                echo "  运行 dotfiles install-aur 引导安装 yay 并装 AUR 包，或手动安装。"
            fi
        else
            echo "⚠ 未检测到 apt-get/dnf/pacman，请手动安装依赖（见 apt-packages.txt / dnf-packages.txt / pacman-packages.txt）"
        fi
        install_tpm              # 装 tpm
        ;;
    *) echo "⚠ 不支持的系统：$(uname -s)" ;;  # 其它系统仅提示
esac
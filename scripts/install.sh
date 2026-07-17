#!/bin/sh
# scripts/install.sh - 按平台安装系统依赖
set -eu
REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)

install_tpm() {
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ -d "$TPM_DIR/.git" ]; then
        echo "  tpm 已存在"
    else
        echo "  安装 tpm (tmux 插件管理器)"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR" || \
            echo "  (tpm 克隆失败，跳过)"
    fi
}

case "$(uname -s)" in
    Darwin)
        if command -v brew >/dev/null 2>&1; then
            echo "==> macOS: brew bundle"
            brew bundle --file="$REPO/Brewfile" --no-lock
        else
            echo "⚠ 未检测到 Homebrew，请先安装：https://brew.sh"
        fi
        install_tpm
        ;;
    Linux)
        if command -v apt-get >/dev/null 2>&1; then
            echo "==> Linux: apt-get install"
            sudo apt-get update
            # shellcheck disable=SC2046
            sudo apt-get install -y $(grep -vE '^\s*#|^\s*$' "$REPO/apt-packages.txt" | tr '\n' ' ')
        else
            echo "⚠ 未检测到 apt-get，请手动安装依赖（见 apt-packages.txt）"
        fi
        install_tpm
        ;;
    *) echo "⚠ 不支持的系统：$(uname -s)" ;;
esac

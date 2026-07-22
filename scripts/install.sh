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
            # 从 apt-packages.txt 读取包名（去掉注释行和空行），传给 apt-get install
            # shellcheck disable=SC2046
            sudo apt-get install -y $(grep -vE '^\s*#|^\s*$' "$REPO/apt-packages.txt" | tr '\n' ' ')
        else
            echo "⚠ 未检测到 apt-get，请手动安装依赖（见 apt-packages.txt）"
        fi
        install_tpm              # 装 tpm
        ;;
    *) echo "⚠ 不支持的系统：$(uname -s)" ;;  # 其它系统仅提示
esac
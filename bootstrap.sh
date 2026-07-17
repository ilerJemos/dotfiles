#!/bin/sh
# bootstrap.sh - 一键引导：克隆 -> 装依赖 -> 建链接
set -eu

REPO_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
REPO_URL="git@github.com:ilerJemos/dotfiles.git"

if [ ! -d "$REPO_DIR/.git" ]; then
    echo "==> 克隆 dotfiles -> $REPO_DIR"
    git clone "$REPO_URL" "$REPO_DIR"
else
    echo "==> 仓库已存在：$REPO_DIR"
fi

cd "$REPO_DIR"

if [ -x scripts/install.sh ]; then
    echo "==> 安装系统依赖"
    ./scripts/install.sh || echo "  (依赖安装跳过/失败，继续)"
fi

echo "==> 部署符号链接"
./scripts/link.sh

echo ""
echo "✅ 引导完成。新开终端或执行：exec \$SHELL"

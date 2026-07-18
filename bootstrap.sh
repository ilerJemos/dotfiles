#!/bin/sh
# bootstrap.sh - 一键引导：装依赖 -> 建链接（仓库需已克隆到本机）
#
# 新机器流程：先 git clone 本仓库到任意目录，cd 进去后执行 ./bootstrap.sh
set -eu

REPO=$(CDPATH= cd "$(dirname "$0")" && pwd)

if [ -x "$REPO/scripts/install.sh" ]; then
    echo "==> 安装系统依赖"
    sh "$REPO/scripts/install.sh" || echo "  (依赖安装跳过/失败，继续)"
fi

echo "==> 部署符号链接"
sh "$REPO/scripts/link.sh"

echo ""
echo "✅ 引导完成。新开终端或执行：exec \$SHELL"

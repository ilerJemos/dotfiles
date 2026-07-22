#!/bin/sh
# bootstrap.sh - 一键引导：装依赖 -> 建链接（仓库需已克隆到本机）
#
# 新机器流程：先 git clone 本仓库到任意目录，cd 进去后执行 ./bootstrap.sh
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

REPO=$(CDPATH= cd "$(dirname "$0")" && pwd)  # 仓库根 = 本文件所在目录

if [ -x "$REPO/scripts/install.sh" ]; then
    echo "==> 安装系统依赖"
    sh "$REPO/scripts/install.sh" || echo "  (依赖安装跳过/失败，继续)"  # 装包失败不阻断后续链接
fi

echo "==> 部署符号链接"
sh "$REPO/scripts/link.sh"       # 建立符号链接到 $HOME（幂等，自动备份既有文件）

echo ""
echo "✅ 引导完成。新开终端或执行：exec \$SHELL"

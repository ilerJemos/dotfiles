#!/bin/sh
# scripts/update.sh - 拉取最新并重新链接
# 等价 `dotfiles update` / `dotfiles_update` shell 函数。
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错
REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录
cd "$REPO"                       # 切到仓库，确保 git 命令作用于本仓库
echo "==> git pull"
git pull --ff-only               # 快进合并拉取（拒绝产生合并提交，避免本地分叉）
echo "==> 重新链接"
sh "$REPO/scripts/link.sh"       # 重新部署符号链接（幂等，会跳过已链接项）

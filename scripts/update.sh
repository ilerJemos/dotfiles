#!/bin/sh
# scripts/update.sh - 拉取最新并重新链接
set -eu
REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$REPO"
echo "==> git pull"
git pull --ff-only
echo "==> 重新链接"
sh "$REPO/scripts/link.sh"

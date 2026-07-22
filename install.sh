#!/bin/sh
# install.sh - 部署入口（= scripts/link.sh 的薄封装）
# 保留在仓库根，方便新机器 `./install.sh` 直接调用。
exec "$(CDPATH= cd "$(dirname "$0")" && pwd)/scripts/link.sh" "$@"  # exec 替换进程，直接跑 link.sh 并透传参数

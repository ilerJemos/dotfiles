#!/bin/sh
# install.sh - 部署入口（= scripts/link.sh 的薄封装）
exec "$(CDPATH= cd "$(dirname "$0")" && pwd)/scripts/link.sh" "$@"

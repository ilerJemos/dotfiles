#!/bin/sh
# scripts/install-brew.sh - 在 macOS 安装 Homebrew（用户态）
#
# 为什么需要：install.sh 的 macOS 分支靠 `brew bundle` 按 Brewfile 装工具，
# 全新机器若没有 brew 只能提示手动安装。此脚本跑官方安装器把 brew 装好，
# 让 bootstrap 在干净 macOS 上一键走通。幂等：已装则跳过。
#
# 用法：sh scripts/install-brew.sh   或   dotfiles install-brew
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

# 仅在 macOS 上运行（本仓库仅 macOS 分支用 brew）
if [ "$(uname -s)" != "Darwin" ]; then
    echo "✗ install-brew 仅在 macOS 上运行（当前 $(uname -s)）" >&2
    exit 1
fi

# 已安装则跳过（幂等）
if command -v brew >/dev/null 2>&1; then
    echo "==> Homebrew 已安装：$(command -v brew)"
    exit 0
fi

command -v curl >/dev/null 2>&1 || { echo "✗ 需要 curl" >&2; exit 1; }  # 依赖检查
command -v bash >/dev/null 2>&1 || { echo "✗ 需要 /bin/bash" >&2; exit 1; }

echo "==> 安装 Homebrew（官方安装脚本 https://brew.sh）"
# 官方一键安装器：curl 拉取脚本后交 /bin/bash 执行（内含 Xcode CLT 检查与交互提示）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装器会把 shellenv 写入 shell profile，但当前进程尚未生效——按可能路径 eval 一次。
# Apple Silicon 装在 /opt/homebrew，Intel 装在 /usr/local，逐一尝试即可。
for _b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$_b" ] && eval "$("$_b" shellenv)" && break  # shellenv 设置 PATH/HOMEBREW_* 供本进程使用
done

if command -v brew >/dev/null 2>&1; then
    echo "==> 完成：$(brew --version | head -1)"      # 打印版本号验证
else
    echo "⚠ 安装似乎完成但 brew 仍不在 PATH；请新开终端后重试" >&2
    exit 1
fi

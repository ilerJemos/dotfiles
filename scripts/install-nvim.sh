#!/bin/sh
# scripts/install-nvim.sh - 从上游装/升级 Neovim 到 0.12+（用户态，免 sudo）
#
# 为什么需要：Ubuntu/Debian 官方源 neovim 常落后（如 0.11.x），而本仓库
# nvim 配置要求 0.12+（vim.pack / ui2）。apt 解决不了，故从 GitHub release
# 的 nvim-linux-x86_64.tar.gz 装到 ~/.local/opt/nvim，并在 ~/.local/bin/nvim
# 建符号链接。~/.local/bin 由 common/path.sh 前置进 PATH，自动覆盖 /usr/bin/nvim。
#
# 用法：sh scripts/install-nvim.sh   或   dotfiles install-nvim
# 幂等：重复执行即下载最新稳定版覆盖升级。
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"  # 最新稳定版 tarball
PREFIX="$HOME/.local/opt"        # 用户级安装根目录
DEST="$PREFIX/nvim"              # 解压目标目录
BIN_LINK="$HOME/.local/bin/nvim" # 可执行符号链接（在 PATH 中）

# 仅支持 Linux x86_64（tarball 名即架构）
if [ "$(uname -s)" != "Linux" ]; then
    echo "✗ 仅支持 Linux（tarball 为 nvim-linux-x86_64）" >&2
    exit 1
fi
if [ "$(uname -m)" != "x86_64" ]; then
    echo "✗ 仅支持 x86_64（当前 $(uname -m)）；其他架构请改用对应 release 资产" >&2
    exit 1
fi

command -v curl >/dev/null 2>&1 || { echo "✗ 需要 curl" >&2; exit 1; }  # 依赖检查

WORK=$(mktemp -d)                # 临时工作目录
trap 'rm -rf "$WORK"' EXIT       # 退出时（含异常）清理临时目录
TGZ="$WORK/nvim-linux-x86_64.tar.gz"  # 下载保存路径

echo "==> 下载 Neovim 最新稳定版"
echo "    $URL"
curl -fL -o "$TGZ" "$URL"        # -f HTTP 错误即失败；-L 跟随重定向

echo "==> 解压到 $DEST"
mkdir -p "$PREFIX"               # 确保父目录存在
rm -rf "$DEST"                   # 清掉旧版本
mkdir -p "$DEST"                 # 重建目标目录
tar -C "$DEST" --strip-components=1 -xzf "$TGZ"  # 解压并去掉顶层目录（--strip-components=1）

echo "==> 链接 $BIN_LINK -> $DEST/bin/nvim"
mkdir -p "$(dirname "$BIN_LINK")"  # 确保 ~/.local/bin 存在
ln -sf "$DEST/bin/nvim" "$BIN_LINK"  # -s 软链；-f 覆盖既有链接

echo "==> 完成"
"$DEST/bin/nvim" --version | head -1  # 打印版本号验证
echo
echo "提示：~/.local/bin 已由 common/path.sh 前置进 PATH，优先于 /usr/bin/nvim。"
echo "      新开终端或 exec \$SHELL 后用 'nvim --version' 验证。"

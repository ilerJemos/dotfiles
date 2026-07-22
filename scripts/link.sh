#!/bin/sh
# scripts/link.sh - 把 dotfiles 符号链接到 $HOME（幂等，自动备份）
set -eu                          # -e 出错即退出；-u 引用未定义变量即报错

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)  # 仓库根 = 本文件上一级目录
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"  # 本次备份目录（带时间戳）
MADE_BACKUP=0                    # 标记本次是否产生过备份

# link_file <src_abs> <dest_abs>
# 已正确链接则跳过；dest 存在但非本链接则备份后覆盖；否则直接建链。
link_file() {
    src=$1 dest=$2
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        printf '  skip   %s (already linked)\n' "$dest"  # 已是指向 src 的链接，跳过
        return 0
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP"       # 确保备份目录存在
        mv "$dest" "$BACKUP/"   # 把既有文件/链接移入备份
        MADE_BACKUP=1
        printf '  backup %s -> %s/\n' "$dest" "$BACKUP"
    fi
    ln -s "$src" "$dest"         # 建立符号链接 dest -> src
    printf '  link   %s -> %s\n' "$dest" "$src"
}

echo "==> config/* -> ~/.config/"
mkdir -p "$HOME/.config"         # 确保 ~/.config 存在
for app in "$REPO"/config/*; do
    [ -e "$app" ] || continue    # 跳过空通配（config/ 为空时）
    link_file "$app" "$HOME/.config/$(basename "$app")"  # config/<app> -> ~/.config/<app>
done

echo "==> home/* -> \$HOME/"
# POSIX sh 的 * 不匹配点文件，故用 .[!.]* ..?* * 覆盖全部条目
for f in "$REPO"/home/.[!.]* "$REPO"/home/..?* "$REPO"/home/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue  # 跳过不存在的通配项
    link_file "$f" "$HOME/$(basename "$f")"
done

echo "==> gitconfig -> ~/.gitconfig"
link_file "$REPO/gitconfig" "$HOME/.gitconfig"  # 全局 git 配置入口

echo "==> bin/* -> ~/.local/bin/ (如有)"
mkdir -p "$HOME/.local/bin"      # 确保 ~/.local/bin 存在
for f in "$REPO"/bin/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue     # 跳过空通配
    chmod +x "$f" 2>/dev/null || true          # 确保可执行（失败不阻断）
    link_file "$f" "$HOME/.local/bin/$(basename "$f")"
done

echo "==> local.sh (本机私有，创建空文件，不同步入库；参考 local/local.sh.example)"
if [ ! -e "$HOME/.config/shell/local.sh" ]; then
    : > "$HOME/.config/shell/local.sh"          # 创建空文件（: > 截断写入空）
    printf '  create %s (空)\n' "$HOME/.config/shell/local.sh"
else
    printf '  skip   %s (已存在)\n' "$HOME/.config/shell/local.sh"
fi

echo "==> ~/.config/zsh/completions (用户私有 zsh 补全目录)"
mkdir -p "$HOME/.config/zsh/completions"        # 确保目录存在，供手动放 _* 补全脚本

echo ""
if [ "$MADE_BACKUP" = 1 ]; then
    echo "完成。原文件已备份到：$BACKUP"
else
    echo "完成。无文件需要备份。"
fi
echo "提示：新开终端或执行 exec \$SHELL 生效。"

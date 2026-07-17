#!/bin/sh
# scripts/link.sh - 把 dotfiles 符号链接到 $HOME（幂等，自动备份）
set -eu

REPO=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
MADE_BACKUP=0

# link_file <src_abs> <dest_abs>
link_file() {
    src=$1 dest=$2
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        printf '  skip   %s (already linked)\n' "$dest"
        return 0
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mkdir -p "$BACKUP"
        mv "$dest" "$BACKUP/"
        MADE_BACKUP=1
        printf '  backup %s -> %s/\n' "$dest" "$BACKUP"
    fi
    ln -s "$src" "$dest"
    printf '  link   %s -> %s\n' "$dest" "$src"
}

echo "==> config/* -> ~/.config/"
mkdir -p "$HOME/.config"
for app in "$REPO"/config/*; do
    [ -e "$app" ] || continue
    link_file "$app" "$HOME/.config/$(basename "$app")"
done

echo "==> home/* -> \$HOME/"
# POSIX sh 的 * 不匹配点文件，故用 .[!.]* ..?* * 覆盖全部条目
for f in "$REPO"/home/.[!.]* "$REPO"/home/..?* "$REPO"/home/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    link_file "$f" "$HOME/$(basename "$f")"
done

echo "==> gitconfig -> ~/.gitconfig"
link_file "$REPO/gitconfig" "$HOME/.gitconfig"

echo "==> bin/* -> ~/.local/bin/ (如有)"
mkdir -p "$HOME/.local/bin"
for f in "$REPO"/bin/*; do
    [ -e "$f" ] || [ -L "$f" ] || continue
    chmod +x "$f" 2>/dev/null || true
    link_file "$f" "$HOME/.local/bin/$(basename "$f")"
done

echo "==> local.sh (本机私有，创建空文件，不同步入库；参考 local/local.sh.example)"
if [ ! -e "$HOME/.config/shell/local.sh" ]; then
    : > "$HOME/.config/shell/local.sh"
    printf '  create %s (空)\n' "$HOME/.config/shell/local.sh"
else
    printf '  skip   %s (已存在)\n' "$HOME/.config/shell/local.sh"
fi

echo "==> ~/.config/zsh/completions (用户私有 zsh 补全目录)"
mkdir -p "$HOME/.config/zsh/completions"

echo ""
if [ "$MADE_BACKUP" = 1 ]; then
    echo "完成。原文件已备份到：$BACKUP"
else
    echo "完成。无文件需要备份。"
fi
echo "提示：新开终端或执行 exec \$SHELL 生效。"

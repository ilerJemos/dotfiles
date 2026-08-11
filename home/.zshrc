# ~/.zshrc — 极薄入口，转发到 XDG 下的真实配置
# 真正的配置在 ~/.config/shell/zsh/zshrc
[ -f "$HOME/.config/shell/zsh/zshrc" ] && source "$HOME/.config/shell/zsh/zshrc"  # 存在则加载真实配置
. "/home/iler/.deno/env"

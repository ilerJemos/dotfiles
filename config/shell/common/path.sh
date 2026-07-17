# common/path.sh - 组装 PATH（POSIX 兼容，bash/zsh 共用）
# 前置用户/语言工具目录；带去重，可重复 source

_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;              # 已存在则跳过
        *) PATH="$1:$PATH" ;;
    esac
}

# 按优先级从低到高前置，最终高优先级排在最前
[ -d "$HOME/go/bin" ]      && _path_prepend "$HOME/go/bin"
[ -d "$HOME/.cargo/bin" ]  && _path_prepend "$HOME/.cargo/bin"
[ -d "$HOME/bin" ]         && _path_prepend "$HOME/bin"
[ -d "$HOME/.local/bin" ]  && _path_prepend "$HOME/.local/bin"

export PATH
unset -f _path_prepend

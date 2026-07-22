# common/path.sh - 组装 PATH（POSIX 兼容，bash/zsh 共用）
# 前置用户/语言工具目录；带去重，可重复 source

# 内部函数：把目录前置到 PATH，已存在则跳过（去重）
_path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;              # 已存在则跳过
        *) PATH="$1:$PATH" ;;     # 否则前置
    esac
}

# 按优先级从低到高前置，最终高优先级排在最前
[ -d "$HOME/go/bin" ]      && _path_prepend "$HOME/go/bin"      # Go 安装的可执行
[ -d "$HOME/.cargo/bin" ]  && _path_prepend "$HOME/.cargo/bin"  # Rust cargo 可执行
[ -d "$HOME/bin" ]         && _path_prepend "$HOME/bin"         # 用户自放脚本
[ -d "$HOME/.local/bin" ]  && _path_prepend "$HOME/.local/bin"  # pip/pipx 等用户级安装

export PATH                                # 导出最终 PATH
unset -f _path_prepend                     # 清理内部函数，避免污染命名空间

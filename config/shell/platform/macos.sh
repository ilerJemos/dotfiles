# platform/macos.sh - macOS 平台特定（POSIX 兼容）

# Homebrew 前缀：Apple Silicon 用 /opt/homebrew，Intel 用 /usr/local
if [ -d /opt/homebrew/bin ]; then
    HOMEBREW_PREFIX=/opt/homebrew                   # Apple Silicon 默认前缀
elif [ -d /usr/local/bin ]; then
    HOMEBREW_PREFIX=/usr/local                      # Intel 默认前缀
fi
export HOMEBREW_PREFIX                              # 导出供其它脚本/工具使用

# Homebrew 工具加入 PATH（去重，优先于系统自带）
if [ -n "$HOMEBREW_PREFIX" ]; then
    case ":$PATH:" in *":$HOMEBREW_PREFIX/sbin:"*) ;; *) PATH="$HOMEBREW_PREFIX/sbin:$PATH" ;; esac  # sbin 前置
    case ":$PATH:" in *":$HOMEBREW_PREFIX/bin:"*) ;; *) PATH="$HOMEBREW_PREFIX/bin:$PATH" ;; esac    # bin 前置
    export PATH
fi

# BSD ls 默认着色
export CLICOLOR=1                                   # 让 BSD ls 默认启用颜色

# platform/macos.sh - macOS 平台特定（POSIX 兼容）

# Homebrew 前缀：Apple Silicon 用 /opt/homebrew，Intel 用 /usr/local
if [ -d /opt/homebrew/bin ]; then
    HOMEBREW_PREFIX=/opt/homebrew
elif [ -d /usr/local/bin ]; then
    HOMEBREW_PREFIX=/usr/local
fi
export HOMEBREW_PREFIX

# Homebrew 工具加入 PATH（去重，优先于系统自带）
if [ -n "$HOMEBREW_PREFIX" ]; then
    case ":$PATH:" in *":$HOMEBREW_PREFIX/sbin:"*) ;; *) PATH="$HOMEBREW_PREFIX/sbin:$PATH" ;; esac
    case ":$PATH:" in *":$HOMEBREW_PREFIX/bin:"*) ;; *) PATH="$HOMEBREW_PREFIX/bin:$PATH" ;; esac
    export PATH
fi

# BSD ls 默认着色
export CLICOLOR=1

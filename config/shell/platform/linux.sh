# platform/linux.sh - Linux 平台特定（POSIX 兼容）
# 通用路径（~/.local/bin 等）由 common/path.sh 统一处理

# snap 工具（Ubuntu 等）
if [ -d /snap/bin ]; then
    case ":$PATH:" in *":/snap/bin:"*) ;; *) PATH="/snap/bin:$PATH" ;; esac
    export PATH
fi

# Debian/Ubuntu 把 bat 重命名为 batcat、fd 重命名为 fdfind。
# 标准名缺失时补回别名，使别名/脚本可统一调用 bat、fd。
# （仅在缺失标准名且存在重命名版时才别名，避免覆盖系统自带。）
command -v bat >/dev/null 2>&1 || { command -v batcat >/dev/null 2>&1 && alias bat='batcat'; }
command -v fd  >/dev/null 2>&1 || { command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'; }

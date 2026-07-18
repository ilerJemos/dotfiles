# common/functions.sh - 常用函数（POSIX 兼容，bash/zsh 共用）
# 仅定义函数，不在 source 时执行任何逻辑，零启动开销。

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1" || return 1
}

# 按扩展名解压压缩包
extract() {
    [ -z "$1" ] && { echo "usage: extract <file>" >&2; return 1; }
    [ -f "$1" ] || { echo "extract: $1: 不是文件" >&2; return 1; }
    case "$1" in
        *.tar.gz|*.tgz)    tar xzf "$1" ;;
        *.tar.bz2|*.tbz2)  tar xjf "$1" ;;
        *.tar.xz|*.txz)    tar xJf "$1" ;;
        *.tar)             tar xf "$1" ;;
        *.zip)             unzip "$1" ;;
        *.gz)              gunzip "$1" ;;
        *.bz2)             bunzip2 "$1" ;;
        *.xz)              unxz "$1" ;;
        *.7z)              7z x "$1" ;;
        *) echo "extract: $1: 未知格式" >&2; return 1 ;;
    esac
}

# --- 代理（proxy）---
# 不同机器的代理地址/端口各不相同，地址写在本机私有文件
# ~/.config/shell/local.sh（不入库，由 install.sh 创建空文件）：
#
#   export DOTFILES_PROXY_URL="http://127.0.0.1:7890"           # HTTP 代理
#   export DOTFILES_PROXY_URL="socks5://127.0.0.1:1080"         # 或 SOCKS5
#   export DOTFILES_NO_PROXY="localhost,127.0.0.1,::1,*.local"  # 可选，有默认
#
# 设计要点（最佳实践）：
#   - 不自动开启：代理未必常驻，需要时手动 `proxy_on`，不用时 `proxy_off`。
#     某机器若希望常驻，在 local.sh 末尾加一行 `proxy_on` 即可。
#   - 只设环境变量：curl / wget / git(libcurl) / npm / pip 等均尊重 *_proxy；
#     不改写 `git config --global`（避免持久化副作用、跨 shell 串扰、忘记关闭）。
#   - 大小写都设：curl 等读小写，Go / Java 等常读大写。
#   - no_proxy 默认排除本地回环，避免本地请求绕行代理。
#   - SSH 协议（git@host:）不走 HTTP 代理，需另配 SSH ProxyCommand。

# 取代理地址：优先参数，其次 DOTFILES_PROXY_URL；都没有则返回 1
_dotfiles_proxy_url() {
    if [ -n "$1" ]; then printf '%s' "$1"; return 0; fi
    if [ -n "$DOTFILES_PROXY_URL" ]; then printf '%s' "$DOTFILES_PROXY_URL"; return 0; fi
    return 1
}

# 开启代理：proxy_on [url]  （url 缺省取 DOTFILES_PROXY_URL）
proxy_on() {
    _purl=$(_dotfiles_proxy_url "$1")
    if [ -z "$_purl" ]; then
        unset _purl
        echo "proxy_on: 未配置代理地址。" >&2
        echo "  在 ~/.config/shell/local.sh 设置：export DOTFILES_PROXY_URL=\"http://host:port\"" >&2
        echo "  或临时指定：proxy_on http://127.0.0.1:7890" >&2
        return 1
    fi
    _pnp="${DOTFILES_NO_PROXY:-localhost,127.0.0.1,::1}"
    # 同时设大小写
    export http_proxy="$_purl"  HTTP_PROXY="$_purl"
    export https_proxy="$_purl" HTTPS_PROXY="$_purl"
    export all_proxy="$_purl"   ALL_PROXY="$_purl"
    export no_proxy="$_pnp"     NO_PROXY="$_pnp"
    echo "proxy on  -> $_purl (no_proxy: $_pnp)"
    unset _purl _pnp
}

# 关闭代理：清空所有相关环境变量
proxy_off() {
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY \
          all_proxy ALL_PROXY no_proxy NO_PROXY
    echo "proxy off -> 已清空代理环境变量"
}

# 查看代理状态
proxy_status() {
    if [ -n "$http_proxy" ]; then
        echo "proxy: ON   http_proxy=$http_proxy"
        echo "         no_proxy=${no_proxy:-（未设）}"
    else
        echo "proxy: OFF"
        [ -n "$DOTFILES_PROXY_URL" ] && \
            echo "  (DOTFILES_PROXY_URL=${DOTFILES_PROXY_URL}；执行 proxy_on 开启)"
    fi
}

# --- dotfiles 自更新 ---
# 拉取最新配置并重新部署符号链接；不重装已安装的命令行工具
# （仅 git pull --ff-only + scripts/link.sh，等价 `dotfiles update`）。
# 经 ~/.config/shell 符号链接定位仓库，不依赖 PATH 上的 dotfiles 命令。
dotfiles_update() {
    (
        _repo=$(CDPATH= cd -P "$HOME/.config/shell/../.." 2>/dev/null && pwd) || {
            echo "dotfiles_update: 无法定位 dotfiles 仓库（~/.config/shell 未链接？先执行 ./install.sh）" >&2
            exit 1
        }
        sh "$_repo/scripts/update.sh"
    )
}

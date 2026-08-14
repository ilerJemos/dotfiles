# common/functions.sh - 常用函数（POSIX 兼容，bash/zsh 共用）
# 仅定义函数，不在 source 时执行任何逻辑，零启动开销。

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1" || return 1  # 建目录（含父目录）并进入；失败返回 1
}

# 按扩展名解压压缩包
extract() {
    [ -z "$1" ] && { echo "usage: extract <file>" >&2; return 1; }  # 缺参数报错
    [ -f "$1" ] || { echo "extract: $1: 不是文件" >&2; return 1; }   # 非文件报错
    case "$1" in
        *.tar.gz|*.tgz)    tar xzf "$1" ;;  # tar.gz / tgz
        *.tar.bz2|*.tbz2)  tar xjf "$1" ;;  # tar.bz2 / tbz2
        *.tar.xz|*.txz)    tar xJf "$1" ;;  # tar.xz / txz
        *.tar)             tar xf "$1" ;;   # tar
        *.zip)             unzip "$1" ;;    # zip
        *.gz)              gunzip "$1" ;;   # gz（非 tar）
        *.bz2)             bunzip2 "$1" ;;  # bz2
        *.xz)              unxz "$1" ;;     # xz
        *.7z)              7z x "$1" ;;     # 7z
        *) echo "extract: $1: 未知格式" >&2; return 1 ;;  # 不支持的格式
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
#   - 环境变量给所有工具：curl / wget / git(libcurl) / npm / pip 等尊重 *_proxy。
#   - git 额外显式写代理到 ~/.config/git/config.proxy（[http]/[https] proxy）：
#     该文件不入库，由 config/git/config 的 [include] 加载，缺失时静默跳过；
#     随 proxy_on/off 增删，不残留、不污染仓库。
#     不用 `git config --global`——会写穿 ~/.gitconfig 符号链接、改脏仓库。
#   - 大小写都设：curl 等读小写，Go / Java 等常读大写。
#   - no_proxy 默认排除本地回环，避免本地请求绕行代理。
#   - SSH 协议（git@host:）不走 HTTP 代理，需另配 SSH ProxyCommand。

# 取代理地址：优先参数，其次 DOTFILES_PROXY_URL；都没有则返回 1
_dotfiles_proxy_url() {
    if [ -n "$1" ]; then printf '%s' "$1"; return 0; fi                          # 有参数：用参数
    if [ -n "$DOTFILES_PROXY_URL" ]; then printf '%s' "$DOTFILES_PROXY_URL"; return 0; fi # 否则用环境变量
    return 1                                                                     # 都没有：失败
}

# 开启代理：proxy_on [url]  （url 缺省取 DOTFILES_PROXY_URL）
proxy_on() {
    _purl=$(_dotfiles_proxy_url "$1")                  # 解析代理地址
    if [ -z "$_purl" ]; then
        unset _purl
        echo "proxy_on: 未配置代理地址。" >&2          # 无地址：提示如何配置
        echo "  在 ~/.config/shell/local.sh 设置：export DOTFILES_PROXY_URL=\"http://host:port\"" >&2
        echo "  或临时指定：proxy_on http://127.0.0.1:7890" >&2
        return 1
    fi
    _pnp="${DOTFILES_NO_PROXY:-localhost,127.0.0.1,::1}"  # no_proxy 默认排除回环
    # 同时设大小写（curl 读小写，Go/Java 常读大写）
    export http_proxy="$_purl"  HTTP_PROXY="$_purl"    # HTTP
    export https_proxy="$_purl" HTTPS_PROXY="$_purl"   # HTTPS
    export all_proxy="$_purl"   ALL_PROXY="$_purl"     # SOCKS 等（all_proxy）
    export no_proxy="$_pnp"     NO_PROXY="$_pnp"       # 不走代理的主机
    # git 显式代理：写入私有配置文件（不入库），config/git/config 经 [include] 加载
    mkdir -p "$HOME/.config/git"                       # 确保目录存在（未链接时也能写）
    printf '[http]\n\tproxy = %s\n[https]\n\tproxy = %s\n' "$_purl" "$_purl" \
        > "$HOME/.config/git/config.proxy"             # 覆盖写入（幂等）
    echo "proxy on  -> $_purl (no_proxy: $_pnp)"       # 反馈当前状态
    unset _purl _pnp                                   # 清理临时变量
}

# 关闭代理：清空所有相关环境变量
proxy_off() {
    unset http_proxy HTTP_PROXY https_proxy HTTPS_PROXY \
          all_proxy ALL_PROXY no_proxy NO_PROXY        # 逐一 unset
    rm -f "$HOME/.config/git/config.proxy"             # 移除 git 代理私有文件
    echo "proxy off -> 已清空代理环境变量"
}

# 查看代理状态
proxy_status() {
    if [ -n "$http_proxy" ]; then
        echo "proxy: ON   http_proxy=$http_proxy"      # 已开启：显示地址
        echo "         no_proxy=${no_proxy:-（未设）}"
    else
        echo "proxy: OFF"                              # 未开启
        [ -n "$DOTFILES_PROXY_URL" ] && \
            echo "  (DOTFILES_PROXY_URL=${DOTFILES_PROXY_URL}；执行 proxy_on 开启)"
    fi
    if [ -f "$HOME/.config/git/config.proxy" ]; then   # git 代理私有文件（proxy_on 写入）
        echo "         git proxy: ON   $HOME/.config/git/config.proxy"
    else
        echo "         git proxy: OFF"
    fi
}

# --- starship 提示符方案切换 ---
# 自由选择 starship 用 Nerd Font 图标方案还是纯 Unicode 方案。
# 用法：starship_font nerd|plain|auto|status
#   nerd   强制 Nerd Font 图标方案（终端已装并启用 Nerd Font 时用）
#   plain  强制纯 Unicode 方案（终端无 Nerd Font / 显示乱码时用）
#   auto   恢复 fc-list 自动检测（默认行为）
#   status 查看当前会话方案与持久化选择
# 持久化：nerd/plain 写入 ~/.config/shell/starship-font（不入库），新终端沿用；
# 当前会话立即生效（starship 每次渲染都读 STARSHIP_CONFIG）。
starship_font() {
    _sf_file="$HOME/.config/shell/starship-font"            # 持久化选择文件
    _sf_nerd="$HOME/.config/starship.toml"                  # Nerd Font 方案配置
    _sf_plain="$HOME/.config/starship-no-nerdfont.toml"     # 纯 Unicode 方案配置
    case "$1" in
        nerd)                                                  # 强制 Nerd Font
            export STARSHIP_CONFIG="$_sf_nerd"
            printf 'nerd' > "$_sf_file"
            echo "starship: Nerd Font 方案（已持久化，新终端沿用）"
            ;;
        plain)                                                 # 强制纯 Unicode
            export STARSHIP_CONFIG="$_sf_plain"
            printf 'plain' > "$_sf_file"
            echo "starship: 纯 Unicode 方案（已持久化，新终端沿用）"
            ;;
        auto)                                                  # 恢复自动检测
            rm -f "$_sf_file"
            unset STARSHIP_CONFIG
            if command -v fc-list >/dev/null 2>&1 && ! fc-list 2>/dev/null | grep -qi "nerd"; then
                export STARSHIP_CONFIG="$_sf_plain"           # fc-list 未检测到 Nerd Font
                echo "starship: 自动检测 -> 纯 Unicode（未检测到 Nerd Font）"
            else
                echo "starship: 自动检测 -> Nerd Font（检测到 Nerd Font 或无 fc-list）"
            fi
            ;;
        status|"")                                             # 查看当前状态
            case "${STARSHIP_CONFIG:-$_sf_nerd}" in
                *no-nerdfont*) _sf_cur="纯 Unicode" ;;
                *)             _sf_cur="Nerd Font" ;;
            esac
            echo "当前会话：$_sf_cur"
            if [ -f "$_sf_file" ]; then
                echo "持久化选择：$(cat "$_sf_file")"
            else
                echo "持久化选择：auto（自动检测）"
            fi
            ;;
        *)                                                     # 用法提示
            echo "用法：starship_font nerd|plain|auto|status" >&2
            return 1
            ;;
    esac
    unset _sf_file _sf_nerd _sf_plain _sf_cur
}

# --- dotfiles 自更新 ---
# 拉取最新配置并重新部署符号链接；不重装已安装的命令行工具
# （仅 git pull --ff-only + scripts/link.sh，等价 `dotfiles update`）。
# 经 ~/.config/shell 符号链接定位仓库，不依赖 PATH 上的 dotfiles 命令。
dotfiles_update() {
    (
        _repo=$(CDPATH= cd -P "$HOME/.config/shell/../.." 2>/dev/null && pwd) || {  # 从 ~/.config/shell 回溯两级定位仓库根
            echo "dotfiles_update: 无法定位 dotfiles 仓库（~/.config/shell 未链接？先执行 ./install.sh）" >&2
            exit 1
        }
        sh "$_repo/scripts/update.sh"                  # 执行更新脚本（pull + 重链）
    )
}

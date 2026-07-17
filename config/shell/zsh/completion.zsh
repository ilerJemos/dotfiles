# config/shell/zsh/completion.zsh
# zsh 补全系统：原生 compinit（不依赖 oh-my-zsh / 任何框架）
#
# 作用：
#   1) 组装 fpath（用户私有 + Homebrew 补全目录）
#   2) 初始化 compinit（dump 每日缓存，秒级启动）
#   3) 增强补全行为（大小写不敏感、菜单选择、分组着色）
#
# 顺序：须在 platform/*.sh 之后（使用 $HOMEBREW_PREFIX），且在依赖 compdef
#       的工具初始化（zoxide 等）之前 source。

# --- 1. fpath：补全函数搜索路径（compinit 之前确定）---
# Homebrew 提供的工具补全（_git / _gh / _brew / _rg / _zoxide ...）
if [ -n "$HOMEBREW_PREFIX" ]; then
    for d in "$HOMEBREW_PREFIX/share/zsh/site-functions" \
             "$HOMEBREW_PREFIX/share/zsh/vendor-completions"; do
        [ -d "$d" ] && fpath=("$d" $fpath)
    done
fi
# 用户私有补全（XDG，不入库；放入 _foo 形式的补全函数即生效）
if [ -d "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions" ]; then
    fpath=("${XDG_CONFIG_HOME:-$HOME/.config}/zsh/completions" $fpath)
fi

# --- 2. compinit（dump 缓存到 XDG cache，每日重建一次拾取新补全）---
autoload -Uz compinit
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${ZSH_COMPDUMP:h}"
# 判断 dump 是否需要重建：缺失/为空，或修改时间超过 24h（拾取新装工具的补全）。
# 注意：文件名生成（含 glob 限定符）在 [[ ]] 内不发生，须在数组赋值上下文进行。
# (Nmh+24) = N 空匹配不报错、mh+24 修改时间超过 24 小时；路径无 glob 字符故可免引号。
typeset -a _stale
_stale=($ZSH_COMPDUMP(Nmh+24))
if [[ -s "$ZSH_COMPDUMP" && ${#_stale} -eq 0 ]]; then
    compinit -C -d "$ZSH_COMPDUMP"   # dump 新鲜 -> 跳过安全检查快速加载
else
    compinit -i -d "$ZSH_COMPDUMP"   # 过期/缺失 -> 重新校验（扫描 fpath，必要时重建；忽略不安全目录）
fi
unset _stale

# 菜单选择需要 complist 模块
zmodload zsh/complist 2>/dev/null

# --- 3. 补全行为增强 ---
# 大小写不敏感：小写可补到大写（输 git 能匹配 GIT）
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# 候选 ≥2 时启用方向键菜单选择
zstyle ':completion:*' menu select=2
# 按描述分组并显示组名
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '── %d ──'
# 候选列表着色（优先 LS_COLORS，否则基础配色：目录蓝/链接紫/可执行红）
if [[ -n "$LS_COLORS" ]]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
else
    zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=36:cd=37'
fi
# 路径补全合并多余斜杠；候选列表紧凑显示
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-packed true

# --- 4. 相关 setopt（补全体验）---
setopt AUTO_MENU         # 连续 Tab 进入菜单选择
setopt COMPLETE_IN_WORD  # 从光标处补全，而非仅行尾
setopt NO_LIST_BEEP      # 补全候选歧义时不响铃

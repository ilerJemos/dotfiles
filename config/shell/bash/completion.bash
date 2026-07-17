# config/shell/bash/completion.bash
# bash 补全：加载 bash-completion 包（若已安装）
#
# - zsh 端用原生 compinit（见 zsh/completion.zsh）；bash 端依赖 bash-completion 包。
# - 装好后，Homebrew 工具的 bash 补全会从 $HOMEBREW_PREFIX/etc/bash_completion.d/
#   被 bash-completion 自动加载（git / gh / etc.）。
# - fzf / zoxide 的补全由各自 init 脚本（bashrc 中 eval）提供。
# - 可选安装：macOS `brew install bash-completion`；Linux `apt install bash-completion`。

# 候选位置（按优先级）：Homebrew v2 -> Homebrew v1 -> Linux 标准路径
for _bc in \
    "${HOMEBREW_PREFIX:-}/etc/profile.d/bash_completion.sh" \
    "${HOMEBREW_PREFIX:-}/etc/bash_completion" \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion; do
    if [ -r "$_bc" ]; then
        # shellcheck source=/dev/null
        source "$_bc"
        break
    fi
done
unset _bc

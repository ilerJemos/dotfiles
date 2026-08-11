# ~/.bash_profile - 登录 shell 入口（SSH 等）
# bash 登录时只读 .bash_profile/.bash_login/.profile，不读 .bashrc，故在此转发。
# 非登录交互式 shell 仍直接读 .bashrc，不受影响。
[ -f ~/.bashrc ] && source ~/.bashrc  # 转发到 .bashrc，使登录 shell 也加载完整配置
. "/home/iler/.deno/env"

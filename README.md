# dotfiles

个人 dotfiles 仓库，面向 **macOS / Linux** 双平台，遵循 [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/latest/) 规范，通过符号链接部署到 `$HOME` 与 `~/.config`。

> 当前版本：**v0.1**（早期阶段，目录结构与脚本持续演进中）

## 设计理念

- **XDG 优先** —— 所有可放在 `~/.config` 的配置都归入 `config/`，保持 `$HOME` 干净整洁。
- **跨平台** —— 通过 `platform/` 区分 macOS 与 Linux，公共配置与平台特定配置分离，同一套仓库在不同系统上都能用。
- **符号链接部署** —— `install.sh` 把仓库目录链接到目标位置，修改源文件即时生效，无需反复复制同步。
- **可定制** —— `local/` 机制支持每台机器的私有配置与密钥，不进入版本控制。
- **幂等安装** —— 脚本可重复执行，只补齐缺失部分，不会破坏已有配置。

## 目录结构

```
~/dotfiles
├── README.md
├── install.sh              # 创建目录、建立符号链接
├── bootstrap.sh            # 一键引导（安装依赖 + 部署，待实现）
├── gitconfig               # git include 文件，指向 ~/.config/git/config
│
├── home/                   # 必须位于 $HOME 的文件
│   ├── .zprofile
│   ├── .bash_profile
│   ├── .gitconfig
│   └── .gitignore
│
├── config/                 # 对应 ~/.config
│   ├── shell/
│   │   ├── common/          # bash & zsh 共享（POSIX 兼容）
│   │   │   ├── env.sh       # 通用环境变量
│   │   │   ├── path.sh      # PATH 组装
│   │   │   ├── alias.sh     # 命令别名
│   │   │   └── functions.sh # 自定义函数
│   │   ├── platform/        # 平台特定（与 shell 无关）
│   │   │   ├── linux.sh
│   │   │   └── macos.sh
│   │   ├── zsh/
│   │   │   └── zshrc        # zsh 入口，按序 source 各模块
│   │   └── bash/
│   │       └── bashrc
│   ├── git/                # ~/.config/git/config 等
│   ├── nvim/               # Neovim 配置
│   ├── kitty/              # kitty 终端
│   ├── tmux/               # tmux
│   ├── starship.toml       # 提示符
│   └── ...
│
├── bin/                    # 自写小工具，加入 PATH
│
├── scripts/                # 安装 / 链接 / 检查 / 更新 脚本
│   ├── install
│   ├── link
│   ├── doctor
│   └── update
│
├── platform/               # 平台级安装逻辑
│   ├── common.sh
│   ├── linux.sh
│   └── macos.sh
│
└── local/                  # 每台机器的私有配置（不纳入版本控制）
    ├── local.sh.example
    └── secrets.example
```

> 注：以上为**目标结构**。v0.1 已实现 `config/shell/` 下的 zsh 入口与平台文件，其余模块逐步补充中。

## Shell 配置架构

`zshrc` 是整个 shell 配置的入口，按以下顺序加载各模块：

1. `common/env.sh` —— 通用环境变量
2. `common/path.sh` —— 组装 `PATH`
3. `common/alias.sh` —— 命令别名
4. `common/functions.sh` —— 自定义函数
5. `platform/{linux,macos}.sh` —— 根据 `uname` 加载平台特定配置
6. `local.sh`（可选）—— 本机私有配置，存在则加载

平台文件示例：

- `macos.sh` —— 设置 `HOMEBREW_PREFIX=/opt/homebrew` 并把 Homebrew 加入 `PATH`
- `linux.sh` —— 把 `~/.local/bin` 加入 `PATH`

## 安装

### 前置要求

- macOS 或 Linux
- `zsh`（推荐）或 `bash`
- `git`

### 步骤

```bash
git clone git@github.com:ilerJemos/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` 会：

- 创建 `~/.config`、`~/.local/share`、`~/.cache` 目录
- 把 `config/` 下的各应用目录符号链接到 `~/.config/`

完成后重新加载 shell 配置，或直接重开终端即可生效。

## 本地定制

机器私有配置放在 `~/.config/zsh/local.sh`（由 `local/local.sh.example` 复制而来），可放置：

- 本机专属的环境变量与别名
- API 密钥等敏感信息（对应 `secrets.example`）

该文件不会被纳入版本控制，可安全存放本机私密内容。

## 许可

个人使用仓库，暂未指定开源协议。

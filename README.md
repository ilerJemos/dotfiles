# dotfiles

跨 **macOS / Linux** 的个人 dotfiles，遵循 [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/latest/)，通过符号链接部署。目标：在不同机器上获得一致的 shell / git / tmux / 编辑器体验。

## 特性

- **XDG 优先**：配置集中在 `config/`，保持 `$HOME` 干净。
- **跨平台**：`platform/` 区分 macOS / Linux，公共配置与平台配置分离。
- **bash/zsh 共享**：`common/` 为 POSIX 兼容的共享模块，两个 shell 复用。
- **符号链接部署**：`scripts/link.sh` 幂等、自动备份，可重复执行。
- **可定制**：`local.sh` 与 git `config.local` 承载本机私有内容，不入库。

## 目录结构

```
~/dotfiles
├── install.sh              # 部署入口 = scripts/link.sh 薄封装
├── bootstrap.sh            # 一键引导：clone + 装依赖 + 链接
├── Brewfile                # macOS 依赖
├── apt-packages.txt        # Linux 依赖
├── gitconfig               # -> ~/.gitconfig (include ~/.config/git/config)
│
├── home/                   # -> $HOME 的入口桩
│   ├── .zshrc
│   ├── .bashrc
│   └── .tmux.conf
│
├── config/                 # -> ~/.config
│   ├── shell/
│   │   ├── common/         # bash/zsh 共享（POSIX 兼容）
│   │   │   ├── env.sh
│   │   │   ├── path.sh
│   │   │   ├── alias.sh
│   │   │   └── functions.sh
│   │   ├── platform/
│   │   │   ├── macos.sh
│   │   │   └── linux.sh
│   │   ├── zsh/
│   │   │   ├── zshrc
│   │   │   └── completion.zsh   # 原生 compinit（不依赖 oh-my-zsh）
│   │   └── bash/
│   │       ├── bashrc
│   │       └── completion.bash
│   ├── git/
│   │   ├── config
│   │   ├── ignore
│   │   └── config.local.example
│   ├── nvim/init.lua
│   ├── tmux/tmux.conf
│   └── starship.toml
│
├── bin/                    # -> ~/.local/bin
│   └── dotfiles
│
├── scripts/
│   ├── link.sh             # 符号链接部署（幂等+备份）
│   ├── install.sh          # 按平台装依赖
│   ├── doctor.sh           # 健康检查
│   └── update.sh           # 拉取 + 重链
│
└── local/
    └── local.sh.example
```

## 快速开始

### 全新机器（一键引导）

```sh
git clone git@github.com:ilerJemos/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh        # 装依赖(brew/apt) + 建链接
```

`bootstrap.sh` 会：克隆（若未克隆）→ `scripts/install.sh` 按平台装依赖 → `scripts/link.sh` 建链接。

### 仅部署链接（依赖已就绪）

```sh
./install.sh          # 等价 scripts/link.sh
```

### 链接了什么

| 仓库 | 目标 |
|------|------|
| `config/<app>` | `~/.config/<app>` |
| `home/.zshrc` / `.bashrc` / `.tmux.conf` | `~/` |
| `gitconfig` | `~/.gitconfig` |
| `bin/*` | `~/.local/bin/*` |

已存在的同名文件会被备份到 `~/.dotfiles-backup/<时间戳>/`；已是正确符号链接则跳过。

## Shell 配置

`~/.zshrc`（`~/.bashrc` 同理）是极薄入口，转发到 `~/.config/shell/zsh/zshrc`，按序加载：

1. `common/env.sh` — EDITOR / PAGER / LANG / XDG
2. `common/path.sh` — PATH 组装（去重）
3. `common/alias.sh` — 别名（eza 优先，回退 GNU/BSD 着色 ls）
4. `common/functions.sh` — `mkcd` / `extract` / `proxy_on` 等
5. `platform/{macos,linux}.sh` — 平台特定（Homebrew 前缀、snap 等）
6. 补全系统 — zsh 原生 compinit / bash bash-completion（须先于依赖 compdef 的工具）
7. starship / fzf / zoxide — 保护式按需加载
8. `local.sh` — 本机私有（可选）

## 补全（自动补全）

- **zsh**：`config/shell/zsh/completion.zsh` 用原生 `compinit`（不依赖 oh-my-zsh 等框架）。
  - `fpath` 自动纳入 Homebrew 补全目录（`$HOMEBREW_PREFIX/share/zsh/site-functions`），故 `git` / `gh` / `brew` / `rg` / `zoxide` 等随 brew 安装即自带补全。
  - 用户私有补全放入 `~/.config/zsh/completions`（由 `link.sh` 创建，不入库），放入 `_foo` 形式的补全函数即生效。
  - dump 缓存在 `$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION`：24h 内 `-C` 快速加载，超期 `-i` 重新校验，启动近乎无开销。
  - 增强：大小写不敏感、方向键菜单选择、分组着色；`AUTO_MENU` / `COMPLETE_IN_WORD` / `NO_LIST_BEEP`。
- **bash**：`config/shell/bash/completion.bash` 加载 `bash-completion` 包（可选依赖，未随仓库安装）。
  - 装好后 Homebrew 工具的 bash 补全会从 `$HOMEBREW_PREFIX/etc/bash_completion.d/` 被自动加载；`fzf` / `zoxide` 的补全由各自 `eval` 提供。
  - 可选安装：macOS `brew install bash-completion`；Linux `apt install bash-completion`。

## 工具配置

- **git**：`config/git/config`（别名、`pull.rebase`、默认分支 `main`、冲突样式 `zdiff3`）。身份放 `config.local`（不入库），从 `config.local.example` 复制。
- **tmux**：`config/tmux/tmux.conf`（vi 模式、鼠标、直观分屏 `|`/`-`、tpm 插件）。经 `~/.tmux.conf` 转发加载（tmux 不自动读 XDG）。
- **starship**：`config/starship.toml`（精简提示符）。
- **neovim**：`config/nvim/init.lua`（精简选项与键位；插件管理器待后续增强）。

## 自定义

- 本机 shell 私有配置：`~/.config/shell/local.sh`（由 `install.sh` 创建**空**文件，不同步入库；参考 `local/local.sh.example`）。
  - 代理：在 `local.sh` 设 `export DOTFILES_PROXY_URL="http://host:port"`，再用 `proxy_on` / `proxy_off` / `proxy_status` 控制（见 `common/functions.sh`）。
- git 身份：`~/.config/git/config.local`（由 `config/git/config.local.example` 复制，不入库）。

## 脚本

| 脚本 | 作用 |
|------|------|
| `scripts/link.sh` | 符号链接部署（幂等 + 备份） |
| `scripts/install.sh` | 按平台装依赖（brew bundle / apt）+ tpm |
| `scripts/doctor.sh` | 环境健康检查（工具 + 链接） |
| `scripts/update.sh` | `git pull` + 重新链接 |
| `bin/dotfiles` | 便捷命令：`dotfiles {update\|status\|doctor\|path}` |

## 平台说明

- **macOS**：用 Homebrew（`Brewfile`）。Homebrew 前缀自动适配 Apple Silicon(`/opt/homebrew`)/Intel(`/usr/local`)。
- **Linux**：用 apt（`apt-packages.txt`）。`eza` / `lazygit` / `git-delta` / `starship` 在 apt 默认源可能缺失，需另装（见 `apt-packages.txt` 注释）。

## 许可

个人使用，暂未指定开源协议。

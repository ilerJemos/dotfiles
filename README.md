~/dotfiles
├── README.md
├── install.sh
├── bootstrap.sh
├── Brewfile                 # macOS
├── apt-packages.txt         # Ubuntu
│
├── home/                    # 放必须位于 $HOME 的文件
│   ├── .zprofile
│   ├── .bash_profile
│   ├── .gitconfig
│   └── .gitignore
│
├── config/                  # 对应 ~/.config
│   ├── shell/
    │   ├── env.sh
    │   ├── path.sh
    │   ├── aliases.sh
    │   ├── functions.sh
    │   ├── platform/
        │   ├── linux.sh
        │   ├── macos.sh.sh
    │   ├── zsh/
        │   ├── zshrc
    │   ├── bash/
        │   ├── bashrc
│   ├── git/
│   ├── nvim/
│   ├── kitty/
│   ├── tmux/
│   ├── starship.toml
│   ├── claude/
│   └── ...
│
├── bin/                     # 自己写的小工具
│
├── scripts/
│   ├── install
│   ├── link
│   ├── doctor
│   └── update
│
├── platform/
│   ├── common.sh
│   ├── linux.sh
│   └── macos.sh
│
└── local/
    ├── local.sh.example
    └── secrets.example

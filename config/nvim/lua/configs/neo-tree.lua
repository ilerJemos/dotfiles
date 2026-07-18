require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  window = {
    position = "left",
    width = 30,
    mappings = {
      ["<space>"] = "none",
    },
  },
  default_component_configs = {
    indent = {
      with_expanders = true,
    },
    git_status = {
      symbols = {
        added = "",
        modified = "",
        deleted = "✖",
        renamed = "➜",
        untracked = "",
        ignored = "",
        unstaged = "",
        staged = "",
        conflict = "",
      },
    },
  },
})

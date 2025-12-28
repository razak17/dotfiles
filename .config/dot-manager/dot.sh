#!/bin/bash

###
### Programs to install by default
###
DOT_MANAGER_COMPLETE_PROGRAMS=(
  "arch"
  "aur"
  "asdf"
  "awscli"
  "bat"
  "browser"
  "bun"
  "cargo"
  "clipmenu"
  "copilot_cli"
  "dev"
  "docker"
  "duckdb"
  "deno"
  "fnm"
  "fzf"
  "golang"
  "jackett"
  "jellyfin"
  "nvim"
  "opencode"
  "postgres"
  "uv"
  "redis"
  "rmpc"
  "suckless"
  "tmux"
  "zsh"
)

# ---------------------------------------------------------------------------
DOT_MANAGER_DIR="$HOME/.config/dot-manager"
DOT_MANAGER_CACHE_DIR="$HOME/.cache/dot-manager"
source "$DOT_MANAGER_DIR/helper.sh"

if [ ! -d "$DOT_MANAGER_CACHE_DIR" ]; then
  mkdir -p "$DOT_MANAGER_CACHE_DIR"
fi

__install_program() {
  local program_name="$1"
  local install_script="$DOT_MANAGER_DIR/install/programs/$program_name.sh"

  if [ -f "$install_script" ]; then
    shift
    if ! source "$install_script" "$@"; then
      log "error" "Failed to source '$program_name' script."
      return 1
    fi
  else
    log "error" "'$program_name' unknown."
    return 1
  fi
}

__install_program_list() {
  local program_list=("$@")

  for program in "${program_list[@]}"; do
    __install_program "$program" || return 1
  done
}

install_packages() {
  print_step "Installing Base Packages"

  if [ "$TERM" = "wezterm" ]; then
    print_step "Setting up wezterm terminfo"
    tempfile=$(mktemp) &&
      curl -sS -o "$tempfile" https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo &&
      tic -x -o "$HOME/.terminfo" "$tempfile" &&
      rm "$tempfile"
  elif [ "$TERM" = "ghostty" ] || [ "$TERM" = "xterm-ghostty" ]; then
    print_step "Setting up ghostty terminfo"
    tempfile=$(mktemp) &&
      curl -sS -o "$tempfile" https://raw.githubusercontent.com/rachartier/dotfiles/refs/heads/main/.config/ghostty/terminfo/ghostty.terminfo &&
      tic -x -o "$HOME/.terminfo" "$tempfile" &&
      rm "$tempfile"
  fi

  print_step "Installing system packages"
  __install_package_arch base-devel \
    wget \
    unzip \
    zip \
    tar \
    unrar \
    ripgrep \
    alacritty \
    ghostty \
    kitty \
    xsel
}

install_complete() {
  print_header "Installing Complete Configuration"
  sudo -v
  install_packages

  __install_program_list "${DOT_MANAGER_COMPLETE_PROGRAMS[@]}"

  git config --global include.path "$HOME/.config/git/gitconfig"
  sudo ldconfig
}

do_reinstall_all() {
  install_complete
}

do_reinstall() {
  local tool_name="$1"

  if [ -z "$tool_name" ]; then
    log "error" "No tool name provided."
    return 1
  fi

  if [ "$tool_name" = "all" ]; then
    do_reinstall_all
    return 0
  fi

  shift
  __install_program "$tool_name" "$@"
}

update_all() {
  log "info" "Updating neovim plugins..."
  "/opt/nvim-linux-x86_64/bin/nvim" --headless "+Lazy! sync" "+qall"

  log "info" "Updating tmux plugins..."
  "$HOME/.config/tmux/plugins/tpm/bin/update_plugins" all
}

show_programs_list() {
  echo "Available programs:"
  for program in "${DOT_MANAGER_COMPLETE_PROGRAMS[@]}"; do
    echo "  - $program"
  done
}

do_tool() {
  local tool_name="$1"
  local tool_path="$DOT_MANAGER_DIR/install/tools/$tool_name.sh"

  if [ ! -f "$tool_path" ]; then
    log "error" "'$tool_name' unknown."
    return 1
  fi

  shift
  source "$tool_path"
}

do_command() {
  case "$1" in
  "list") show_programs_list ;;
  "init") install_complete ;;
  "update") update_all ;;
  "docker") install_docker ;;
  "terminal")
    shift
    source "$DOT_MANAGER_DIR/install/terminal.sh" "$@"
    ;;
  "fonts")
    shift
    source "$DOT_MANAGER_DIR/install/fonts.sh" "$@"
    ;;
  "reinstall")
    shift
    do_reinstall "$@"
    ;;
  "tool")
    shift
    do_tool "$@"
    ;;
  "migrate")
    shift
    source "$DOT_MANAGER_DIR/migrate.sh" "$@"
    ;;
  *) __git_dot "$@" ;;
  esac
}

if [ $# -eq 0 ]; then
  __git_dot "$@"
else
  do_command "$@"
fi

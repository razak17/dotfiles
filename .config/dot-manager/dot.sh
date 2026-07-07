#!/bin/bash

###
### Programs to install by default
###
DOT_MANAGER_COMPLETE_PROGRAMS=(
  "arch"
  "aur"
  "awscli"
  "bat"
  "browser"
  "cargo"
  "clipmenu"
  "copilot_cli"
  "dev"
  "docker"
  "duckdb"
  "fnm"
  "fzf"
  "golang"
  "jackett"
  "jellyfin"
  "mech"
  "mise"
  "nvim"
  "opencode"
  "redis"
  "rmpc"
  "stripe"
  "suckless"
  "tmux"
  "yazi"
  "zsh"
)

# ---------------------------------------------------------------------------
DOT_MANAGER_DIR="$HOME/.config/dot-manager"
DOT_MANAGER_CACHE_DIR="$HOME/.cache/dot-manager"
source "$DOT_MANAGER_DIR/helper.sh"

mkdir -p "$DOT_MANAGER_CACHE_DIR"
: >"$DOT_MANAGER_LOG"

__install_program() {
  local program_name="$1"
  local install_script="$DOT_MANAGER_DIR/install/programs/$program_name.sh"

  if [ -f "$install_script" ]; then
    shift
    if ! source "$install_script" "$@"; then
      log "error" "Failed to source '$program_name' script. (details: $DOT_MANAGER_LOG)"
      return 1
    fi
  else
    log "error" "'$program_name' unknown. Run 'dot list' to see available programs."
    return 1
  fi
}

__install_program_list() {
  local failed=()
  local total=$#
  local i=0

  sudo -v
  SECONDS=0

  for program in "$@"; do
    i=$((i + 1))
    DOT_STEP_PREFIX="[$i/$total]"
    __install_program "$program" || failed+=("$program")
  done
  unset DOT_STEP_PREFIX

  log "success" "$((total - ${#failed[@]}))/$total programs installed in $((SECONDS / 60))m$((SECONDS % 60))s"

  if [ ${#failed[@]} -gt 0 ]; then
    log "error" "Failed: ${failed[*]} (rerun with: dot reinstall <name>, details: $DOT_MANAGER_LOG)"
    return 1
  fi
}

install_packages() {
  print_step "Installing Base Packages"
  sudo -v

  local terminfo_url=""
  case "$TERM" in
  "wezterm") terminfo_url="https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo" ;;
  "ghostty" | "xterm-ghostty") terminfo_url="https://raw.githubusercontent.com/rachartier/dotfiles/refs/heads/main/.config/ghostty/terminfo/ghostty.terminfo" ;;
  esac

  if [ -n "$terminfo_url" ]; then
    print_step "Setting up $TERM terminfo"
    tempfile=$(mktemp) &&
      curl -sS -o "$tempfile" "$terminfo_url" &&
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
    7zip \
    ripgrep \
    alacritty \
    ghostty \
    kitty \
    xsel
}

install_complete() {
  print_step "Installing Complete Configuration"
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

  if [ -z "$tool_name" ] && command -v fzf >/dev/null; then
    tool_name=$(basename -s .sh "$DOT_MANAGER_DIR"/install/programs/*.sh | fzf --prompt='reinstall> ')
    [ -z "$tool_name" ] && return 0
    __install_program "$tool_name"
    return
  fi

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

show_help() {
  cat <<EOF
Usage: dot <command> [args]

Commands:
  list                     List default programs
  init                     Install the complete configuration
  update                   Update nvim and tmux plugins
  program <name|all>       Install a program (or all default programs)
  reinstall <name|all>     Reinstall a program (or everything)
  fonts update             Install Nerd Fonts
  tool <name>              Run a tool script (e.g. dotnet)
  help                     Show this help

Any other command is passed to git on the dotfiles repository.
EOF
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
  "help" | "-h" | "--help") show_help ;;
  "init") install_complete ;;
  "update") update_all ;;
  "program")
    shift
    if [ "$1" == "all" ]; then
      __install_program_list "${DOT_MANAGER_COMPLETE_PROGRAMS[@]}"
    else
      __install_program "$@"
    fi
    ;;
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
  *) __git_dot "$@" ;;
  esac
}

if [ $# -eq 0 ]; then
  __git_dot "$@"
else
  do_command "$@"
fi

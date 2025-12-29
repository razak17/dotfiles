#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_fnm() {
  print_step "Installing fnm..."

  if __is_program_installed "bun"; then
    log "info" "fnm is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.local/share/fnm/fnm" ]; then
    log "info" "Removing old fnm symlink."
    rm "$HOME/.local/share/fnm/fnm"
  fi

  curl -fsSL https://fnm.vercel.app/install | bash

  log "success" "fnm installed."
}

fnm_complete_setup() {
  log "info" "Setting up fnm completions..."

  if ! command -v fnm &>/dev/null; then
    log "error" "fnm is not installed. Please install fnm first."
    return 1
  fi

  if [ -f "$HOME/.config/zsh/plugins/fnm/_fnm" ]; then
    log "info" "Removing old fnm completions."
    rm "$HOME/.config/zsh/plugins/fnm/_fnm"
  fi

  fnm completions --shell zsh >"$HOME/.config/zsh/plugins/fnm/_fnm"

  log "success" "fnm completions set up."
}

install_versions() {
  fnm list
  fnm install v18.0.0
  fnm install v16.13.0
  fnm install v25.0.0
  fnm default v25.0.0
}

install_fnm "$@"
fnm_complete_setup
install_versions

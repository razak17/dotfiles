#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_opencode() {
  print_step "Installing OpenCode..."

  if __is_program_installed "opencode"; then
    log "info" "OpenCode is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.opencode/bin/opencode" ]; then
    log "info" "Removing old OpenCode symlink."
    rm "$HOME/.opencode/bin/opencode"
  fi

  curl -fsSL https://opencode.ai/install | bash

  log "success" "OpenCode installed."
}

install_opencode "$@"

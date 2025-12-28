#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_bun() {
  print_step "Installing Bun..."

  if __is_program_installed "bun"; then
    log "info" "bun is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.bun/bin/bun" ]; then
    log "info" "Removing old Bun symlink."
    rm "$HOME/.bun/bin/bun"
  fi

  curl -fsSL https://bun.sh/install | bash

  log "success" "Bun installed."
}

install_bun "$@"

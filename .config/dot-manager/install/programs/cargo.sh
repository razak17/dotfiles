#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_cargo() {
  print_step "Installing Cargo..."

  if command -v cargo >/dev/null 2>&1; then
    log "info" "Cargo is already installed."
    return
  fi

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  rustup default nightly

  log "success" "Cargo installed."
}

install_cargo "$@"

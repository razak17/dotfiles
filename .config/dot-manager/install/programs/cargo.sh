#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_cargo() {
  print_step "Installing Cargo..."

  if command -v cargo >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "Cargo is already installed."
    return
  fi

  if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Cargo."
    return 1
  fi

  rustup default nightly

  log "success" "Cargo installed."
}

install_cargo "$@"

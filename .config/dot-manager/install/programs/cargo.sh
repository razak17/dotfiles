#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: Rust and Cargo are now managed by install/programs/mise.sh. The
# legacy implementation below is intentionally retained for reference, but this
# script no longer invokes it.

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

print_step "Cargo installer (retired)"
log "error" "The Cargo installer is retired. Rust and Cargo are managed by mise; run 'dot install mise'."
return 1 2>/dev/null || exit 1

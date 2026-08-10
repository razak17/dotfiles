#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: Bun is now managed by install/programs/mise.sh. The legacy
# implementation below is intentionally retained for reference, but this script
# no longer invokes it.

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

  if ! curl -fsSL https://bun.sh/install | bash >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Bun."
    return 1
  fi

  log "success" "Bun installed."
}

print_step "Bun installer (retired)"
log "error" "The Bun installer is retired. Bun is managed by mise; run 'dot install mise'."
return 1 2>/dev/null || exit 1

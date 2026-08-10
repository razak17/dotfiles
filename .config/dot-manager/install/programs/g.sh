#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: Go versions are now managed by install/programs/mise.sh. The legacy
# implementation below is intentionally retained for reference, but this script
# no longer invokes it.

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download g."
    return
  fi

  curl -sSL https://git.io/g-install | sh -s
}

install_g() {
  print_step "Installing g..."

  if [ -f "$HOME/go/bin/g" ]; then
    log "info" "g is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "g installed."
}

reinstall_g() {
  print_step "Reinstalling g..."

  if [ -f "$HOME/go/bin/g" ]; then
    log "info" "Removing old g symlink."
    rm "$HOME/go/bin/g"
  fi

  if ! [ -f "$HOME/go/bin/g" ]; then
    log "error" "g is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "g reinstalled."
}

print_step "g (retired)"
log "error" "g is retired. Go versions are managed by mise; run 'dot install mise'."
return 1 2>/dev/null || exit 1

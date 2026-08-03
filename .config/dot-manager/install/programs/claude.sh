#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download Claude."
    return
  fi

  if ! curl -fsSL https://claude.ai/install.sh | bash >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Claude."
    return 1
  fi
}

install_claude() {
  print_step "Installing Claude..."

  if __is_program_installed "claude"; then
    log "info" "Claude is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Claude installed."
}

reinstall_claude() {
  print_step "Reinstalling Claude..."

  if ! __is_program_installed "claude"; then
    log "error" "Claude is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "Claude reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_claude "$@" ;;
  reinstall) reinstall_claude "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_claude "$@"
else
  do_program_install "$@"
fi

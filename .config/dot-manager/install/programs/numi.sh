#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download Codex."
    return
  fi

  if ! curl -fsSL https://s.numi.app/cli | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Numi."
    return 1
  fi

}

install_numi() {
  print_step "Installing Numi..."

  if __is_program_installed "numi"; then
    log "info" "numi is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Numi installed."
}

reinstall_numi() {
  print_step "Reinstalling Numi..."

  if ! __is_program_installed "numi"; then
    log "error" "Numi is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "Numi reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_numi "$@" ;;
  reinstall) reinstall_numi "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_numi "$@"
else
  do_program_install "$@"
fi

#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download AWS CLI."
    return
  fi

  if [ -f "$HOME/.opencode/bin/opencode" ]; then
    log "info" "Removing old OpenCode symlink."
    rm "$HOME/.opencode/bin/opencode"
  fi

  curl -fsSL https://opencode.ai/install | bash
}

install_opencode() {
  print_step "Installing OpenCode..."

  if __is_program_installed "opencode"; then
    log "info" "OpenCode is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "OpenCode installed."
}

reinstall_opencode() {
  print_step "Reinstalling OpenCode..."

  if ! __is_program_installed "opencode"; then
    log "error" "OpenCode is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "OpenCode reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_opencode "$@" ;;
  reinstall) reinstall_opencode "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_opencode "$@"
else
  do_program_install "$@"
fi

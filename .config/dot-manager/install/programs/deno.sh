#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download Deno."
    return
  fi

  if ! curl -fsSL https://deno.land/x/install/install.sh | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Deno."
    return 1
  fi
}

install_deno() {
  print_step "Installing Deno..."

  if __is_program_installed "deno"; then
    log "info" "Deno is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Deno installed."
}

reinstall_deno() {
  print_step "Reinstalling Deno..."

  if ! __is_program_installed "deno"; then
    log "error" "Deno is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "Deno reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_deno "$@" ;;
  reinstall) reinstall_deno "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_deno "$@"
else
  do_program_install "$@"
fi

#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: uv is now managed by install/programs/mise.sh. The legacy
# implementation below is retained for reference, but this script no longer
# invokes it.

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download uv."
    return
  fi

  if ! curl -LsSf https://astral.sh/uv/install.sh | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install uv."
    return 1
  fi
}

install_uv() {
  print_step "Installing uv"

  if __is_program_installed "uv"; then
    log "info" "uv is already installed. Skipping installation."
    return
  fi

  install_binary

  # uv self update

  log "success" "uv installed."
}

reinstall_uv() {
  print_step "Reinstalling uv"

  if ! __is_program_installed "uv"; then
    log "error" "uv is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "uv reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_uv "$@" ;;
  reinstall) reinstall_uv "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

print_step "uv installer (retired)"
log "error" "The uv installer is retired. uv is managed by mise; run 'dot program mise'."
return 1 2>/dev/null || exit 1

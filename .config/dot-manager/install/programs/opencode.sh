#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: OpenCode is now managed by install/programs/mise.sh. The legacy
# implementation below is retained for reference, but this script no longer
# invokes it.

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download AWS CLI."
    return
  fi

  if [ -f "$HOME/.opencode/bin/opencode" ]; then
    log "info" "Removing old OpenCode symlink."
    rm "$HOME/.opencode/bin/opencode"
  fi

  if ! curl -fsSL https://opencode.ai/install | bash >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install OpenCode."
    return 1
  fi
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

print_step "OpenCode installer (retired)"
log "error" "The OpenCode installer is retired. OpenCode is managed by mise; run 'dot program mise'."
return 1 2>/dev/null || exit 1

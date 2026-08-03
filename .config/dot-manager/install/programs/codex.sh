#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download Codex."
    return
  fi

  if ! curl -fsSL https://chatgpt.com/codex/install.sh | bash >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install Codex."
    return 1
  fi
}

install_codex() {
  print_step "Installing Codex..."

  if __is_program_installed "codex"; then
    log "info" "Codex is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Codex installed."
}

reinstall_codex() {
  print_step "Reinstalling Codex..."

  if ! __is_program_installed "codex"; then
    log "error" "Codex is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "Codex reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_codex "$@" ;;
  reinstall) reinstall_codex "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_codex "$@"
else
  do_program_install "$@"
fi

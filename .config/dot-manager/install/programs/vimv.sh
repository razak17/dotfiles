#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download vimv."
    return
  fi

  if ! curl -fsSL "https://raw.githubusercontent.com/thameera/vimv/master/vimv" \
    -o "$HOME/.local/bin/vimv"; then
    log "error" "Failed to install vimv."
    return 1
  fi

  chmod +755 ~/.local/bin/vimv
}

install_vimv() {
  print_step "Installing vimv..."

  if __is_program_installed "vimv"; then
    log "info" "vimv is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "vimv installed."
}

reinstall_vimv() {
  print_step "Reinstalling vimv..."

  if ! __is_program_installed "vimv"; then
    log "error" "vimv is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "vimv reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_vimv "$@" ;;
  reinstall) reinstall_vimv "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_vimv "$@"
else
  do_program_install "$@"
fi

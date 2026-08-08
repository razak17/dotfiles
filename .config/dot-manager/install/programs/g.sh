#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

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

do_program_install() {
  case "$1" in
  install) install_g "$@" ;;
  reinstall) reinstall_g "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_g "$@"
else
  do_program_install "$@"
fi

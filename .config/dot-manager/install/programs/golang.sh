#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download GoLang."
    return
  fi

  curl -sSL https://git.io/g-install | sh -s
}

install_golang() {
  print_step "Installing GoLang..."

  if [ -f "$HOME/go/bin/g" ]; then
    log "info" "Removing old GoLang symlink."
    rm "$HOME/go/bin/g"
  fi

  install_binary

  log "success" "GoLang installed."
}

reinstall_golang() {
  print_step "Reinstalling GoLang..."

  if ! [ -f "$HOME/go/bin/g" ]; then
    log "error" "GoLang is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "GoLang reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_golang "$@" ;;
  reinstall) reinstall_golang "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_golang "$@"
else
  do_program_install "$@"
fi

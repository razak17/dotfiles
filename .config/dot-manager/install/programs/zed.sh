#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download RustDesk."
    return 1
  fi

  curl -f https://zed.dev/install.sh | ZED_CHANNEL=preview sh
}

install_zed() {
  print_step "Installing zed..."

  if __is_program_installed "zed"; then
    log "info" "zed is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "zed installed."
}

reinstall_zed() {
  print_step "Reinstalling zed..."

  if ! __is_program_installed "zed"; then
    log "error" "zed is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "zed reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_zed ;;
  reinstall) reinstall_zed ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  do_program_install "install"
else
  do_program_install "$1"
fi

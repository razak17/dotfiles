#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  log "download" "Downloading Clipmenu..."
  git clone https://github.com/cdown/clipmenu "$tmp_dir/clipmenu" >/dev/null
  cd "$tmp_dir/clipmenu" || return
  make PREFIX="$HOME/.local" install >/dev/null
}

install_clipmenu() {
  print_step "Installing Clipmenu..."

  if __is_program_installed "clipmenu"; then
    log "info" "clipmenu is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Clipmenu installed."
}

reinstall_clipmenu() {
  print_step "Reinstalling Clipmenu..."

  if ! __is_program_installed "clipmenu"; then
    log "error" "Clipmenu is not installed. Cannot reinstall."
    return
  fi

  install_binary

  log "success" "Clipmenu reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_clipmenu ;;
  reinstall) reinstall_clipmenu ;;
  *)
    log "error" "Unknown action: $1"
    return
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_clipmenu "$@"
else
  do_program_install "$@"
fi

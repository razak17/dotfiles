#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_chafa() {
  print_step "Installing Chafa..."

  if command -v chafa >/dev/null 2>&1; then
    log "info" "Chafa is already installed."
    return
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  log "download" "Cloning Chafa repository"
  git clone --depth 1 https://github.com/hpjansson/chafa.git "$tmp_dir/chafa" >/dev/null && log "success" "Cloned Chafa repository." || return 1

  log "info" "Building Chafa"
  cd "$tmp_dir/chafa" || return 1
  ./autogen.sh >/dev/null && log "success" "Generated build files." || return 1
  make >/dev/null && log "success" "Built Chafa." || return 1
  sudo make install >/dev/null && log "success" "Installed Chafa." || return 1
}

do_program_install() {
  case "$1" in
  install) install_chafa ;;
  reinstall)
    if ! command -v chafa >/dev/null 2>&1; then
      log "error" "Chafa is not installed. Cannot reinstall."
      return 1
    fi
    install_chafa
    ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  do_program_install install
else
  do_program_install "$1"
fi

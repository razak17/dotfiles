#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "wget"; then
    log "error" "wget is required to download RustDesk."
    return 1
  fi

  VERSION=$(__get_latest_release "pingdotgg/t3code")
  url="https://github.com/pingdotgg/t3code/releases/download/$VERSION/T3-Code-${VERSION#v}-x86_64.AppImage"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  log "download" "Downloading T3-Code"
  wget -nv -q -O "$tmp_dir/t3code.AppImage" "$url" >/dev/null && log "success" "Downloaded T3-Code." || return 1
  chmod +x "$tmp_dir/t3code.AppImage"
  mv "$tmp_dir/t3code.AppImage" "$HOME/.local/bin/t3code"
}

install_t3code() {
  print_step "Installing T3-Code..."

  if __is_program_installed "t3code"; then
    log "info" "T3-Code is already installed. Skipping installation."
    return 0
  fi

  install_binary

  log "success" "T3-Code installed."
}

reinstall_t3code() {
  print_step "Reinstalling T3-Code..."

  if ! __is_program_installed "t3code"; then
    log "error" "T3-Code is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "T3-Code reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_t3code ;;
  reinstall) reinstall_t3code ;;
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

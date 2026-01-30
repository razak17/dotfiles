#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "wget"; then
    log "error" "wget is required to download RustDesk."
    return 1
  fi

  RUSTDESK_VERSION=$(__get_latest_release "rustdesk/rustdesk")
  url="https://github.com/rustdesk/rustdesk/releases/download/$RUSTDESK_VERSION/rustdesk-${RUSTDESK_VERSION}-x86_64.AppImage"

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  log "download" "Downloading RustDesk"
  wget -nv -q -O "$tmp_dir/rustdesk.AppImage" "$url" >/dev/null && log "success" "Downloaded RustDesk." || return 1
  chmod +x "$tmp_dir/rustdesk.AppImage"
  mv "$tmp_dir/rustdesk.AppImage" "$HOME/.local/bin/rustdesk"
}

install_rustdesk() {
  print_step "Installing RustDesk..."

  if __is_program_installed "rustdesk"; then
    log "info" "RustDesk is already installed. Skipping installation."
    return 0
  fi

  install_binary

  log "success" "RustDesk installed."
}

reinstall_rustdesk() {
  print_step "Reinstalling RustDesk..."

  if ! __is_program_installed "rustdesk"; then
    log "error" "RustDesk is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  log "success" "RustDesk reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_rustdesk ;;
  reinstall) reinstall_rustdesk ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_rustdesk "$@"
else
  do_program_install "$@"
fi

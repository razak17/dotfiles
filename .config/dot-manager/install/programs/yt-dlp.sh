#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download yt-dlp."
    return
  fi

  if [ -f "$HOME/.local/bin/yt-dlp" ]; then
    log "info" "Removing old yt-dlp installation."
    rm "$HOME/.local/bin/yt-dlp"
  fi

  if ! curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to download yt-dlp."
    return 1
  fi
}

install_yt_dlp() {
  print_step "Installing yt-dlp..."

  if __is_program_installed "yt-dlp"; then
    log "info" "yt-dlp is already installed. Skipping installation."
    return
  fi

  install_binary

  chmod a+rx ~/.local/bin/yt-dlp # Make executable

  log "success" "yt-dlp installed."
}

reinstall_yt_dlp() {
  print_step "Reinstalling yt-dlp..."

  if ! __is_program_installed "yt-dlp"; then
    log "error" "yt-dlp is not installed. Cannot reinstall."
    return 1
  fi

  install_binary

  chmod a+rx ~/.local/bin/yt-dlp # Make executable

  log "success" "yt-dlp reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_yt_dlp "$@" ;;
  reinstall) reinstall_yt_dlp "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_yt_dlp "$@"
else
  do_program_install "$@"
fi

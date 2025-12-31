#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_yt_dlp() {
  print_step "Installing yt-dlp..."

  if __is_program_installed "yt-dlp"; then
    log "info" "yt-dlp is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.local/bin/yt-dlp" ]; then
    log "info" "Removing old yt-dlp installation."
    rm "$HOME/.local/bin/yt-dlp"
  fi

  curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
  chmod a+rx ~/.local/bin/yt-dlp # Make executable

  log "success" "yt-dlp installed."
}

install_yt_dlp "$@"

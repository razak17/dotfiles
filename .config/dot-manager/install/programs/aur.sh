#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_paru() (
  local paru_root

  print_step "Installing paru..."

  if command -v paru >>"$DOT_MANAGER_LOG" 2>&1; then
    log "info" "paru is already installed."
    return 0
  fi

  log "info" "Installing dependencies for paru..."
  if ! __install_package_arch git base-devel rust; then
    log "error" "Failed to install paru build dependencies."
    return 1
  fi

  if ! paru_root=$(mktemp -d); then
    log "error" "Failed to create a temporary paru build directory."
    return 1
  fi
  trap 'rm -rf "$paru_root"' EXIT

  log "info" "Cloning paru repository..."
  if ! git clone https://aur.archlinux.org/paru.git "$paru_root/paru"; then
    log "error" "Failed to clone the paru repository."
    return 1
  fi

  log "info" "Building and installing paru..."
  if ! cd "$paru_root/paru"; then
    log "error" "Failed to enter the paru build directory."
    return 1
  fi
  if ! makepkg -i --noconfirm; then
    log "error" "Failed to build and install paru."
    return 1
  fi

  hash -r
  if ! command -v paru >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "paru was not available after installation."
    return 1
  fi

  log "success" "paru installed."
)

install_aur_essentials() {
  print_step "Installing AUR essentials"

  if ! __install_package_aur fastfetch \
    toilet linux-wifi-hotspot ttf-joypixels ttf-ancient-fonts \
    rmtrash localsend-bin stpv-git w3m newsraft yazi obsidian dysk \
    lrcget-bin autorandr; then
    log "error" "Failed to install one or more AUR essentials."
    return 1
  fi

  log "success" "AUR essentials installed."
}

install_paru "$@" && install_aur_essentials

#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_paru() {
  print_step "Installing paru..."

  if command -v paru &>/dev/null; then
    log "info" "paru is already installed."
    return
  fi

  log "info" "Installing dependencies for paru..."
  __install_package_arch git base-devel

  log "info" "Cloning paru repository..."
  git clone https://aur.archlinux.org/paru.git /tmp/paru

  log "info" "Building and installing paru..."
  cd /tmp/paru || return
  makepkg -si --noconfirm

  log "success" "paru installed."
}

install_aur_essentials() {
  print_step "Installing AUR essentials"

  __install_package_aur fastfetch \
    toilet linux-wifi-hotspot ttf-joypixels ttf-ancient-fonts \
    rmtrash localsend-bin stpv-git w3m newsraft yazi obsidian dysk \
    lrcget-bin autorandr

  log "success" "AUR essentials installed."
}

install_paru "$@"
install_aur_essentials

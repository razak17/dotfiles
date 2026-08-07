#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_paru() (
  local package_path
  local packages=()
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

  log "info" "Building paru..."
  if ! cd "$paru_root/paru"; then
    log "error" "Failed to enter the paru build directory."
    return 1
  fi
  if ! makepkg --noconfirm; then
    log "error" "Failed to build paru."
    return 1
  fi

  mapfile -t packages < <(makepkg --packagelist)
  if [ ${#packages[@]} -eq 0 ]; then
    log "error" "paru build produced no installable packages."
    return 1
  fi
  for package_path in "${packages[@]}"; do
    if [ ! -f "$package_path" ]; then
      log "error" "Built paru package not found: $package_path"
      return 1
    fi
  done

  log "info" "Installing paru..."
  if ! __as_root pacman -U --noconfirm --needed "${packages[@]}"; then
    log "error" "Failed to install the built paru package."
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

  if ! __install_package_aur fastfetch freeze \
    toilet linux-wifi-hotspot ttf-joypixels ttf-ancient-fonts \
    rmtrash localsend-bin stpv-git w3m newsraft yazi obsidian dysk \
    lrcget-bin autorandr; then
    log "error" "Failed to install one or more AUR essentials."
    return 1
  fi

  log "success" "AUR essentials installed."
}

install_paru "$@" && install_aur_essentials

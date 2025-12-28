#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_bat() {
  print_step "Installing Bat"

  log "info" "Installing bat via pacman..."
  __install_package_arch bat

  if ! [ -d "$(bat --config-dir)/themes" ]; then
    log "info" "Installing bat themes..."
    mkdir -p "$(bat --config-dir)/themes"
    wget -nv -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
    wget -nv -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
    wget -nv -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
    wget -nv -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme

    log "success" "bat themes installed."
    bat cache --build
  fi
}

install_bat "$@"

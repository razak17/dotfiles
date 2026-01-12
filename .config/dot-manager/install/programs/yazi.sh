#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_yazi() {
  print_step "Installing yazi..."

  if __is_program_installed "yazi"; then
    log "info" "yazi is already installed. Skipping installation."
    return
  fi

  log "info" "Installing yazi dependencies via pacman..."
  __install_package_arch yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick

  log "success" "yazi installed."
}

yazi_setup() {
  print_step "Setting up yazi..."

  CONFIG_DIR="$HOME/.config/yazi"
  FLAVORS_DIR="$CONFIG_DIR/flavors"

  log "info" "Creating configuration directory at $CONFIG_DIR..."
  mkdir -p "$CONFIG_DIR"

  log "info" "Creating flavors directory at $FLAVORS_DIR..."
  mkdir -p "$FLAVORS_DIR"

  log "info" "Downloading catppuccin-frappe theme..."
  if [ ! -d "$FLAVORS_DIR/catppuccin-frappe.yazi" ]; then
    ya pkg add yazi-rs/flavors:catppuccin-frappe
  fi

  log "success" "yazi setup completed."
}

install_yazi "$@"
yazi_setup "$@"

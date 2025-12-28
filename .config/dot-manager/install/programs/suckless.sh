#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_suckless_utils() {
  log "info" "Installing suckless utilities..."

  if [ ! -d "$HOME/.dots/dwm" ]; then
    git clone https://github.com/razak17/dwm "$HOME/.dots/dwm"
  fi

  log "info" "Installing dwm"
  sudo make -C "$HOME/.dots/dwm" install

  DIR="$HOME/.dots/suckless"

  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    git clone https://github.com/razak17/suckless "$DIR"
  fi

  log "info" "Installing dmenu"
  sudo make -C "$DIR/dmenu" install

  log "info" "Installing st"
  sudo make -C "$DIR/st" install

  log "info" "Installing dwmblocks"
  sudo make -C "$DIR/dwmblocks" install
}

install_suckless_utils "$@"

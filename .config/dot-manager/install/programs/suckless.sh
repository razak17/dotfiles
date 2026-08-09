#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_suckless_utils() {
  print_step "Installing suckless utilities..."

  DIR="$HOME/.dots/suckless"

  if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
    git clone https://github.com/razak17/suckless "$DIR"
  fi

  print_step "Installing dwm"
  __as_root make -C "$DIR/dwm" install

  print_step "Installing dmenu"
  __as_root make -C "$DIR/dmenu" install

  print_step "Installing st"
  __as_root make -C "$DIR/st" install

  print_step "Installing dwmblocks"
  __as_root make -C "$DIR/dwmblocks" install

  log "success" "Suckless utilities installed."
}

install_suckless_utils "$@"

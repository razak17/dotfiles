#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_tmux() {
  print_step "Installing Tmux"

  log "info" "Installing tmux via pacman..."
  sudo pacman -S --noconfirm tmux

  log "info" "Installing tmux plugins manager"
  if ! [ -d "$HOME"/.config/tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME"/.config/tmux/plugins/tpm
  fi

  log "info" "Installing tmux plugins"
  "$HOME"/.config/tmux/plugins/tpm/bin/install_plugins

  log "success" "Tmux installation completed"
}

ftmux_setup() {
  print_step "Setting up ftmux"

  if [ ! -d "$HOME/.dots/ftmux" ]; then
    git clone https://github.com/razak17/ftmux "$HOME/.dots/ftmux"
  fi

  if [ -f "$HOME/.local/bin/ftmux" ]; then
    log "info" "Removing old ftmux symlink."
    rm "$HOME/.local/bin/ftmux"
    ln -s "$HOME"/.dots/ftmux/ftmux "$HOME/.local/bin/ftmux"
  fi

  log "success" "ftmux setup completed"
}

install_tmux "$@"
ftmux_setup

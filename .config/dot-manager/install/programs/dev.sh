#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_dev_essentials() {
  print_step "Installing Dev essentials"

  __install_package_arch github-cli

  __install_package_aur cloc mongodb-compass-bin slack-desktop bruno \
    dbeaver visual-studio-code-bin cloudflared

  log "success" "Dev essentials installed."
}

install_dev_essentials "$@"

#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_stripe() {
  print_step "Installing Stripe CLI..."

  if __is_program_installed "stripe"; then
    log "info" "Stripe CLI is already installed. Skipping installation."
    return
  fi

  VERSION=$(__get_latest_release "stripe/stripe-cli")

  __install_package_release "https://github.com/stripe/stripe-cli/releases/download/$VERSION/stripe_${VERSION#v}_linux_x86_64.tar.gz" "stripe"

  log "success" "Stripe CLI installed."
}

install_stripe "$@"

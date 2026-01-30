#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_binary() {

  VERSION=$(__get_latest_release "stripe/stripe-cli")

  __install_package_release "https://github.com/stripe/stripe-cli/releases/download/$VERSION/stripe_${VERSION#v}_linux_x86_64.tar.gz" "stripe"
}

install_stripe() {
  print_step "Installing Stripe CLI..."

  if __is_program_installed "stripe"; then
    log "info" "Stripe CLI is already installed. Skipping installation."
    return
  fi

  install_binary

  log "success" "Stripe CLI installed."
}

reinstall_stripe() {
  print_step "Reinstalling Stripe CLI..."

  if ! __is_program_installed "stripe"; then
    log "error" "Stripe CLI is not installed. Cannot reinstall."
    return
  fi

  install_binary

  log "success" "Stripe CLI reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_stripe ;;
  reinstall) reinstall_stripe ;;
  *)
    log "error" "Unknown action: $1"
    return
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_stripe "$@"
else
  do_program_install "$@"
fi

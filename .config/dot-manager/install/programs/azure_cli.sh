#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_azure_cli() {
  print_step "Installing Azure CLI..."

  if __is_program_installed "az"; then
    log "info" "Azure CLI is already installed. Skipping installation."
    return
  fi

  if ! __install_package_arch azure-cli; then
    log "error" "Failed to install Azure CLI."
    return 1
  fi

  log "success" "Azure CLI installed."
}

install_azure_cli "$@"

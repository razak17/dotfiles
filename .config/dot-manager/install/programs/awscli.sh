#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_awscli() {
  print_step "Installing AWS CLI..."

  if command -v aws >/dev/null 2>&1; then
    log "info" "awscli is already installed. Skipping installation."
    return
  fi

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip /tmp/awscliv2.zip -d /tmp
  rm /tmp/awscliv2.zip
  sudo /tmp/aws/install

  log "success" "AWS CLI installed."
}

install_awscli "$@"

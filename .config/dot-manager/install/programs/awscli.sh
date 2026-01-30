#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# see: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

install_or_update_binary() {
  if ! __is_program_installed "curl"; then
    log "error" "curl is required to download AWS CLI."
    return
  fi

  if ! __is_program_installed "unzip"; then
    log "error" "unzip is required to install AWS CLI."
    return
  fi

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  log "download" "Downloading AWS CLI..."
  curl -fL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp_dir/awscliv2.zip"
  unzip -q "$tmp_dir/awscliv2.zip" -d "$tmp_dir"

  if [ "$1" = "update" ]; then
    "$tmp_dir/aws/install" --install-dir "$HOME"/.local/awscli --bin-dir "$HOME"/.local/bin --update
    return
  fi

  "$tmp_dir/aws/install" --install-dir "$HOME"/.local/awscli --bin-dir "$HOME"/.local/bin
}

install_awscli() {
  print_step "Installing AWS CLI..."

  if __is_program_installed "aws"; then
    log "info" "awscli is already installed. Skipping installation."
    return
  fi

  install_or_update_binary

  log "success" "AWS CLI installed."
}

update_awscli() {
  print_step "Updating AWS CLI..."

  if ! __is_program_installed "aws"; then
    log "error" "awscli is not installed. Cannot update."
    return
  fi

  install_or_update_binary "update"

  log "success" "AWS CLI updated."
}

reinstall_awscli() {
  print_step "Reinstalling AWS CLI..."

  log "info" "Removing existing AWS CLI installation..."
  [ -d "$HOME/.local/awscli" ] && rm -rf "$HOME/.local/awscli"
  [ -f "$HOME/.local/bin/aws" ] && rm -f "$HOME/.local/bin/aws"
  [ -f "$HOME/.local/bin/aws_completer" ] && rm -f "$HOME/.local/bin/aws_completer"

  install_or_update_binary

  log "success" "AWS CLI reinstalled."
}

do_program_install() {
  case "$1" in
  install) install_awscli "$@" ;;
  update) update_awscli "$@" ;;
  reinstall) reinstall_awscli "$@" ;;
  *)
    log "error" "Unknown action: $1"
    return
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_awscli "$@"
else
  do_program_install "$@"
fi

#!/usr/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

shell_setup() {
  local shell_name=${1:-}
  local shells_file="${DOT_MANAGER_SHELLS_FILE:-/etc/shells}"
  local account_record
  local candidate
  local current_shell
  local shell_path=""
  local username

  if [ "$shell_name" != "zsh" ]; then
    log "error" "Unsupported shell: ${shell_name:-<none>}"
    echo "Usage: dot shell zsh"
    return 1
  fi

  if [ "$(__effective_uid)" -eq 0 ]; then
    log "error" "Refusing to change the root login shell. Run dot shell zsh without sudo."
    return 1
  fi

  if ! command -v chsh >/dev/null 2>&1; then
    log "error" "chsh is not installed."
    return 1
  fi

  if [ -r "$shells_file" ]; then
    while IFS= read -r candidate; do
      if [ "${candidate##*/}" = "zsh" ] && [ -x "$candidate" ]; then
        shell_path=$candidate
        break
      fi
    done <"$shells_file"
  fi

  if [ -z "$shell_path" ]; then
    log "error" "No installed Zsh executable is listed in $shells_file."
    return 1
  fi

  if ! username=$(id -un); then
    log "error" "Could not determine the current user."
    return 1
  fi
  if ! account_record=$(getent passwd "$username"); then
    log "error" "Could not determine the login shell for $username."
    return 1
  fi
  current_shell=${account_record##*:}
  if [ -z "$current_shell" ]; then
    log "error" "Could not determine the login shell for $username."
    return 1
  fi
  if [ "$current_shell" = "$shell_path" ]; then
    log "info" "$shell_path is already the login shell."
    return 0
  fi

  if ! chsh -s "$shell_path"; then
    log "error" "Failed to change the login shell to $shell_path."
    return 1
  fi

  log "success" "Login shell changed to $shell_path. Log out and back in to apply it."
}

shell_setup "$@"

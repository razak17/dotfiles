#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

# Retired: DuckDB is now managed by install/programs/mise.sh. The legacy
# implementation below is retained for reference, but this script no longer
# invokes it.

install_duckdb() {
  print_step "Installing DuckDB..."

  if __is_program_installed "duckdb"; then
    log "info" "DuckDB is already installed. Skipping installation."
    return
  fi

  if [ -f "$HOME/.local/bin/duckdb" ]; then
    log "info" "Removing old DuckDB symlink."
    rm "$HOME/.local/bin/duckdb"
  fi

  if [ -f "$HOME/.duckdb/cli/latest/duckdb" ]; then
    log "info" "Removing old DuckDB CLI symlink."
    rm "$HOME/.duckdb/cli/latest/duckdb"
  fi

  if ! curl https://install.duckdb.org | sh >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install DuckDB."
    return 1
  fi

  if [ ! -f "$HOME/.duckdb/cli/latest/duckdb" ]; then
    ln -s "$HOME/.local/bin/duckdb" "$HOME/.duckdb/cli/latest/duckdb"
  fi

  log "success" "DuckDB installed."
}

print_step "DuckDB installer (retired)"
log "error" "The DuckDB installer is retired. DuckDB is managed by mise; run 'dot program mise'."
return 1 2>/dev/null || exit 1

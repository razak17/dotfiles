#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

zsh_setup() {
  print_step "Setting up Zsh..."

  OH_MY_ZSH="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins"
  PLUGINS="$HOME/.config/zsh/plugins"

  log "info" "Setting up git completions..."
  if [ ! -f "$PLUGINS/git" ]; then
    mkdir -p "$PLUGINS/git"
    cd "$PLUGINS/git" || return 1
    curl -fsSL $OH_MY_ZSH/git/git.plugin.zsh --output git.plugin.zsh
    curl -fsSL $OH_MY_ZSH/git/README.md --output README.md
  fi

  log "info" "Setting up npm completions..."
  if [ ! -f "$PLUGINS/npm" ]; then
    mkdir -p "$PLUGINS/npm"
    cd "$PLUGINS/npm" || return 1
    curl -fsSL $OH_MY_ZSH/npm/npm.plugin.zsh --output npm.plugin.zsh
    curl -fsSL $OH_MY_ZSH/npm/README.md --output README.md
  fi

  log "info" "Setting up yarn completions..."
  if [ ! -f "$PLUGINS/yarn" ]; then
    mkdir -p "$PLUGINS/yarn"
    cd "$PLUGINS/yarn" || return 1
    curl -fsSL $OH_MY_ZSH/yarn/yarn.plugin.zsh --output yarn.plugin.zsh
    curl -fsSL $OH_MY_ZSH/yarn/README.md --output README.md
    curl -fsSL $OH_MY_ZSH/yarn/_yarn --output _yarn
  fi

  log "info" "Setting up pass completions..."
  if [ ! -f "$PLUGINS/pass" ]; then
    mkdir -p "$PLUGINS/pass"
    cd "$PLUGINS/pass" || return 1
    curl -fsSL $OH_MY_ZSH/pass/README.md --output README.md
    curl -fsSL $OH_MY_ZSH/pass/_pass --output _pass
  fi

  log "success" "Zsh setup completed."
}
zsh_setup "$@"

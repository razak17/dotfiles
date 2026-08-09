#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -r -- "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_HOME=$(cd "$DOT_MANAGER_ROOT/../.." && pwd)
AGENT_ENV="$DOTFILES_HOME/.config/ssh/session/agent-env.sh"
AGENT_SHUTDOWN="$DOTFILES_HOME/.config/ssh/session/agent-shutdown.sh"
PLASMA_ENV="$DOTFILES_HOME/.config/plasma-workspace/env/20-ssh-agent.sh"
PLASMA_SHUTDOWN="$DOTFILES_HOME/.config/plasma-workspace/shutdown/ssh-agent.sh"
ADD_KEY="$DOTFILES_HOME/.local/bin/ssh-add-github-session"
AUTOSTART="$DOTFILES_HOME/.config/autostart/ssh-add-github-session.desktop"
XINITRC="$DOTFILES_HOME/.config/x11/xinitrc"

for file in \
  "$AGENT_ENV" \
  "$AGENT_SHUTDOWN" \
  "$PLASMA_ENV" \
  "$PLASMA_SHUTDOWN" \
  "$ADD_KEY" \
  "$XINITRC"; do
  [[ -f "$file" ]]
  /bin/sh -n "$file"
done

[[ -f "$AUTOSTART" ]]
grep -q '^OnlyShowIn=KDE;' "$AUTOSTART"
grep -q 'ssh-add-github-session' "$AUTOSTART"
grep -q 'ssh/session/agent-env.sh' "$PLASMA_ENV"
grep -q 'ssh/session/agent-shutdown.sh' "$PLASMA_SHUTDOWN"
grep -q 'ssh/session/agent-env.sh' "$XINITRC"
grep -q 'ssh/session/agent-shutdown.sh' "$XINITRC"
grep -q 'ssh-add-github-session' "$XINITRC"
grep -q 'trap cleanup_ssh_agent 0' "$XINITRC"

env -i \
  HOME="$TEST_ROOT/home" \
  PATH=/usr/bin:/bin \
  /bin/sh -c '
    set -eu
    mkdir -p "$HOME"
    . "$1"
    test -S "$SSH_AUTH_SOCK"
    test "$DOTFILES_SSH_AGENT_PID" = "$SSH_AGENT_PID"
    first_pid=$SSH_AGENT_PID

    . "$1"
    test "$SSH_AGENT_PID" = "$first_pid"

    "$2"
    if ssh-add -l >/dev/null 2>&1; then
      exit 1
    fi

    mkdir -p "$HOME/.ssh"
    mkdir -p "$HOME/bin"
    printf "#!/bin/sh\nexit 1\n" > "$HOME/bin/ksshaskpass"
    chmod 755 "$HOME/bin/ksshaskpass"
    PATH="$HOME/bin:$PATH"
    export PATH
    ssh-keygen -q -t rsa -N "" -f "$HOME/.ssh/id_rsa_p15v"
    "$2"
    ssh-add -l | grep -q RSA
    "$2"
    test "$(ssh-add -l | wc -l)" -eq 1

    . "$3"
    tries=0
    while kill -0 "$first_pid" 2>/dev/null && [ "$tries" -lt 50 ]; do
      sleep 0.02
      tries=$((tries + 1))
    done
    ! kill -0 "$first_pid" 2>/dev/null
  ' _ "$AGENT_ENV" "$ADD_KEY" "$AGENT_SHUTDOWN"

printf 'SSH agent tests passed\n'

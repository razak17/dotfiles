#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -r -- "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DOTFILES_HOME=$(cd "$DOT_MANAGER_ROOT/../.." && pwd)
AGENT_ENV="$DOTFILES_HOME/.config/plasma-workspace/env/20-ssh-agent.sh"
AGENT_SHUTDOWN="$DOTFILES_HOME/.config/plasma-workspace/shutdown/ssh-agent.sh"
ADD_KEY="$DOTFILES_HOME/.local/bin/ssh-add-github-session"
AUTOSTART="$DOTFILES_HOME/.config/autostart/ssh-add-github-session.desktop"

for file in "$AGENT_ENV" "$AGENT_SHUTDOWN" "$ADD_KEY"; do
  [[ -f "$file" ]]
  /bin/sh -n "$file"
done

[[ -f "$AUTOSTART" ]]
grep -q '^OnlyShowIn=KDE;' "$AUTOSTART"
grep -q 'ssh-add-github-session' "$AUTOSTART"

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
    ssh-keygen -q -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519_github"
    "$2"
    ssh-add -l | grep -q ED25519
    "$2"
    test "$(ssh-add -l | wc -l)" -eq 1

    . "$3"
    ! kill -0 "$first_pid" 2>/dev/null
  ' _ "$AGENT_ENV" "$ADD_KEY" "$AGENT_SHUTDOWN"

printf 'SSH agent tests passed\n'

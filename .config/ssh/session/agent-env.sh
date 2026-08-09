#!/bin/sh

if [ -z "${SSH_AUTH_SOCK:-}" ] || [ ! -S "$SSH_AUTH_SOCK" ]; then
  if [ -x /usr/bin/ssh-agent ]; then
    eval "$(/usr/bin/ssh-agent -s)" >/dev/null
    export SSH_AUTH_SOCK SSH_AGENT_PID
    DOTFILES_SSH_AGENT_PID=$SSH_AGENT_PID
    export DOTFILES_SSH_AGENT_PID
  fi
fi

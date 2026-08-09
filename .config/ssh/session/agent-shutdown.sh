#!/bin/sh

if [ -n "${DOTFILES_SSH_AGENT_PID:-}" ] && \
  [ "${SSH_AGENT_PID:-}" = "$DOTFILES_SSH_AGENT_PID" ]; then
  /usr/bin/ssh-agent -k >/dev/null 2>&1 || true
fi

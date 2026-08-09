#!/bin/sh

ssh_agent_env="${XDG_CONFIG_HOME:-$HOME/.config}/ssh/session/agent-env.sh"
[ -r "$ssh_agent_env" ] && . "$ssh_agent_env"
unset ssh_agent_env

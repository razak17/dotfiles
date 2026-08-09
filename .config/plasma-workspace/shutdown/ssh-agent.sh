#!/bin/sh

ssh_agent_shutdown="${XDG_CONFIG_HOME:-$HOME/.config}/ssh/session/agent-shutdown.sh"
[ -r "$ssh_agent_shutdown" ] && . "$ssh_agent_shutdown"
unset ssh_agent_shutdown

#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[ -f "$HOME/.config/sh/prompt.sh" ] && source "$HOME/.config/sh/prompt.sh"
[ -f "$HOME/.config/sh/aliases.sh" ] && source "$HOME/.config/sh/aliases.sh"
[ -f "$HOME/.config/sh/exports.sh" ] && source "$HOME/.config/sh/exports.sh"

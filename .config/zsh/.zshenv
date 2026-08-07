[ -r "$HOME/.config/shell/environment.sh" ] && . "$HOME/.config/shell/environment.sh"
[ -f $HOME/.config/zsh/zshenv ] && . $HOME/.config/zsh/zshenv
[ -f $HOME/.config/shell/profile ] && . $HOME/.config/shell/profile
[ -f $HOME/.dots/sensitive/secrets.env ] && . $HOME/.dots/sensitive/secrets.env

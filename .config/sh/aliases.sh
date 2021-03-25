# Bash
alias a="nvim ~/.config/sh/aliases.sh"
alias bs='source ~/.bashrc'
alias b="nvim ~/.bashrc"
alias z="zsh"

# General
alias i='sudo'
alias is='sudo su'
alias v="nvim ."
alias nv="nvim"
alias cl='clear'
alias c='clear'
# alias cat="ccat"
alias clocale="dpkg-reconfigure locales"
alias al="nvim ~/.config/alacritty/alacritty.yml"

# Ranger
alias f="ranger"
alias rc='ranger ~/.config'
alias repos='ranger ~/Repos'

# Pacman
alias p='sudo pacman -S'
alias r='sudo pacman -Rs'
alias y='yay -S'
alias update='sudo pacman -Syyu'

# Tmux
alias x="tmux"
alias xls="tmux ls"
alias nx='tmux new -s'
alias ax='tmux attach -t'
alias xc="nvim ~/.tmux.conf"

# Youtube DL
alias dydl='youtube_dl'
alias ydlformat='youtube_dl -F'
alias ydldf='youtube_dl -f'

# Sudo
# alias p='sudo apt-get install'
# alias sg='sudo apt-get install'
# alias r='sudo apt-get remove'
# alias rg='sudo apt-get remove'
# alias am='sudo apt autoremove'
# alias ag='apt list --upgradable'
# alias upd='sudo apt-get update'
# alias upg='sudo apt-get upgrade'
# alias upgf='sudo apt full-upgrade'
# Allow third-party repos (Parrot os)
# alias insecupd='sudo apt-get update --allow-insecure-repositories'
# alias unauthupd='sudo apt-get update --allow-unauthenticated'
# Add your user to a group
alias uadd='sudo usermod -aG'
# Connect to role
alias crole='sudo -iu'
# Apt installs
# alias pl='sudo apt list --installed'
# Install from list
# alias ipl='sudo xargs -a packages_list.txt apt install'
# Installs count
# alias ipc='sudo dpkg-query -f '${binary:Package}\n' -W | wc -l'
# Save list of all installed packages to txt file
# alias ipcf='sudo dpkg-query -f '${binary:Package}\n' -W > packages_list.txt'

# Others
alias plague='curl https://corona-stats.online/states/us'
# alias condapython='/root/anaconda3/bin/python'
alias juiceshop='docker run --rm -p 3000:3000 bkimminich/juice-shop'
alias incwatchers='echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p'

# Refresh fonts directory
alias rfonts='fc-cache -vf ~/.local/share/fonts/'
alias remfonts='fc-cache -f -v'

# Misc
alias lg='lazygit'
alias gp='git add . && git commit -m "auto push" && git push'
alias kill_vbox="kill $(ps -e | grep VirtualBox | awk '{ print $1 }')"
alias list_systemctl="systemctl list-unit-files --state=enabled"
alias set_python_path="source set_python_path"

# Bookmarks
# Ex: wr evaluates to the absolute path to your user's home directory.
export wr=~/Dev/
export cc=~/Dev/Code
export sw=/home/razakmo/.local/share/nvim/swap
export pr=~/Dev/projects
export ql=~/Dev/projects/gql
export ut=~/Dev/utils
export cp=~/Dev/cp
export ds=~/Dev/ds
export sc=~/Dev/py/scripts
export doc=~/Documents
export dw=~/Downloads
export nv=~/.config/nvim
# export vs=~/vscodium/bin/codium
# export tlg=~/Telegram/Telegram
export pa=/media/razak/55CD-9C80/PortableApps

alias cdwr='cd "$wr"'
alias cdcc='cd "$cc"'
alias cdsw='cd "$sw"'
alias cdpr='cd "$pr"'
alias cdql='cd "$ql"'
alias cdut='cd "$ut"'
alias cdcp='cd "$cp"'
alias cdds='cd "$ds"'
alias cdsc='cd "$sc"'
alias cdoc='cd "$doc"'
alias cddw='cd "$dw"'
alias cdcc='cd "$cc"'
alias cdnv='cd "$nv"'
alias cdnv='cd "$nv"'
# alias code="$vs"
# alias gram="$tlg"
alias cdpa='cd "$pa"'


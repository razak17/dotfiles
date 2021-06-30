#/bin/sh

conf() {
  /usr/bin/git --git-dir=$HOME/.dots/dotfiles/ --work-tree=$HOME $@
}

installDotfiles() {
  git clone --bare https://github.com/razak17/dotfiles $HOME/.dots/dotfiles
  conf checkout
  if [ $? = 0 ]; then
    echo "Checked out dotfiles...";
  else
    mkdir -p ~/.config-backup
    echo "Backing up pre-existing dot files.";
    conf checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.config-backup/{}
  fi;
  conf checkout
  conf config --local status.showUntrackedFiles no
}

setupUtils() {
  touch ~/.Xresources
  touch ~/.gtkrc-2.0.mine
  touch ~/.config/zsh/.zshrc
  echo . ~/.config/x11/xresources > ~/.Xresources
  echo . ~/.config/zsh/zshrc > ~/.config/zsh/.zshrc
}

installDotfiles
setupUtils

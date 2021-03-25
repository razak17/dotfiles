#!/bin/bash

YAY="yay -S"
PAC="sudo pacman -S"

# Install packages
pac_packages=(
  'firefox'
  'keepassxc'
  # 'thunderbird'
  'tmux'
  'ranger'
  'docker'
  'postgresql'
  'qbittorrent'
  'ninja'
  'cmake'
  'redshift'
  'mpv'
  'xclip'
  # 'whatsapp-nativefier'
  # 'telegram-desktop'
  'htop'
  'vlc'
  # 'brave'
  # 'clang'
  # 'powerline-fonts'
  'ripgrep'
)

for i in ${pac_packages[@]}; do
  echo item: $i
  $PAC $i
done

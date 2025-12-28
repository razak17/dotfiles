#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_arch_essentials() {
  print_step "Installing Arch essentials"

  __install_package_arch pacman-contrib fd gcc lf \
    xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight \
    xorg-xprop xorg-xinput xorg-xdpyinfo arc-gtk-theme grub-customizer \
    wireless_tools imagemagick bluez bluez-utils blueman openvpn btop \
    xf86-input-libinput android-tools android-file-transfer ninja glow \
    zathura zathura-ps zathura-pdf-poppler zathura-djvu zathura-cb \
    brightnessctl sxiv nsxiv maim hwinfo ueberzug lolcat tokei eza \
    ttf-times-new-roman pandoc aspell aspell-en dunst xclip hyperfine \
    mediainfo mpv mpd mpc pipewire pipewire-pulse wireplumber picom \
    aria2 cowsay ranger screenkey ncmpcpp redshift zoxide cmatrix \
    thunderbird syncthing lazygit git-delta slock gparted baobab \
    bottom plocate rsync reflector gvfs gvfs-mtp zsync ntfs-3g \
    direnv ctags libnotify strace mtools expac dosfstools elinks \
    entr freeze global libconfig pngquant pamixer

  log "success" "Arch essentials installed."
}

install_arch_essentials "$@"

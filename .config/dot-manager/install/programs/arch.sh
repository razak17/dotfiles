#!/bin/env bash

source "$DOT_MANAGER_DIR/helper.sh"

install_arch_essentials() {
  print_step "Installing Arch essentials"

  __install_package_arch pacman-contrib fd gcc lf \
    xorg-server xorg-xinit xorg-xkill xorg-xsetroot xorg-xbacklight \
    xorg-xprop xorg-xinput xorg-xdpyinfo arc-gtk-theme grub-customizer \
    wireless_tools imagemagick bluez bluez-utils blueman openvpn btop \
    xf86-input-libinput android-tools android-file-transfer ninja \
    zathura zathura-ps zathura-pdf-poppler zathura-djvu zathura-cb \
    brightnessctl sxiv nsxiv maim hwinfo ueberzug lolcat eza \
    ttf-times-new-roman pandoc aspell aspell-en dunst xclip hyperfine \
    mediainfo mpv mpd mpc pipewire pipewire-pulse wireplumber picom \
    aria2 cowsay ranger ncmpcpp redshift zoxide cmatrix \
    thunderbird syncthing lazygit slock gparted baobab \
    plocate rsync reflector gvfs gvfs-mtp ntfs-3g \
    ctags libnotify strace mtools expac dosfstools elinks \
    entr libconfig pamixer

  log "success" "Arch essentials installed."
}

install_arch_extras() {
  # These packages are in the extras repo, but not installed by default

  print_step "Installing Arch extras"

  __install_package_arch artix-archlinux-support

  # You need to enable the artix-archlinux-support repo in /etc/pacman.conf to install these packages
  # see: https://wiki.artixlinux.org/Main/Repositories

  __install_package_arch glow tokei screenkey git-delta bottom zsync direnv freeze global pngquant

  log "success" "Arch extras installed."

}

do_program_install() {
  case "$1" in
  essentials) install_arch_essentials ;;
  extras) install_arch_extras ;;
  *)
    log "error" "Unknown action: $1"
    return 1
    ;;
  esac
}

if [ $# -eq 0 ]; then
  install_arch_essentials "$@"
else
  do_program_install "$@"
fi

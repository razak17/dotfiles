#!/bin/env bash

__detect_distro() {
  if grep -qi 'arch' /etc/os-release; then
    echo "arch"
  elif grep -qi 'ubuntu' /etc/os-release; then
    echo "ubuntu"
  else
    echo "unknown"
  fi
}

if [ -n "$__HELPER_ALREADY_LOADED" ]; then
  return 0
fi

show_spinner() {
  local pid=$1
  local message=$2
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local delay=0.1

  while [ "$(ps a | awk '{print $1}' | grep "$pid")" ]; do
    for frame in $(echo $frames | grep -o .); do
      echo -ne "\r${COLORS[cyan]}$frame${COLORS[reset]} $message"
      sleep $delay
    done
  done
  echo -ne "\r${COLORS[green]}${ICON_SUCCESS}${COLORS[reset]} $message\n"
}

print_step() {
  local message="$1"
  echo
  echo -e "${COLORS[blue]}${ICON_GEAR} ${COLORS[bold]}$message${COLORS[reset]}"
}

print_separator() {
  line=$(printf ─%.0s $(seq 1 60))
  echo -e "\n${COLORS[dim]}${line}${COLORS[reset]}\n"
}

print_header() {
  local title="$1"
  local width=60
  local title_length=${#title}

  # Calculate padding for centering
  local padding_left=$(((width - title_length) / 2))
  local padding_right=$((width - title_length - padding_left))

  # Create the repeated characters
  local horizontal_line
  horizontal_line=$(printf '─%.0s' $(seq 1 $width))
  local padding_spaces_left
  padding_spaces_left=$(printf ' %.0s' $(seq 1 $padding_left))
  local padding_spaces_right
  padding_spaces_right=$(printf ' %.0s' $(seq 1 $padding_right))

  # Build the box
  local top_border="${COLORS[cyan]}╭${horizontal_line}╮${COLORS[reset]}"
  local middle_line="${COLORS[cyan]}│${COLORS[reset]}${padding_spaces_left}${COLORS[bold]}${title}${COLORS[reset]}${padding_spaces_right}${COLORS[cyan]}│${COLORS[reset]}"
  local bottom_border="${COLORS[cyan]}╰${horizontal_line}╯${COLORS[reset]}"

  # Print the header box
  echo
  echo -e "$top_border"
  echo -e "$middle_line"
  echo -e "$bottom_border"
  echo
}

declare -A COLORS=(
  ["reset"]="\033[0m"
  ["bold"]="\033[1m"
  ["dim"]="\033[2m"
  ["italic"]="\033[3m"
  ["underline"]="\033[4m"

  ["black"]="\033[30m"
  ["red"]="\033[31m"
  ["green"]="\033[32m"
  ["yellow"]="\033[33m"
  ["blue"]="\033[34m"
  ["magenta"]="\033[35m"
  ["cyan"]="\033[36m"
  ["white"]="\033[37m"

  ["bg_black"]="\033[40m"
  ["bg_red"]="\033[41m"
  ["bg_green"]="\033[42m"
  ["bg_yellow"]="\033[43m"
  ["bg_blue"]="\033[44m"
  ["bg_magenta"]="\033[45m"
  ["bg_cyan"]="\033[46m"
  ["bg_white"]="\033[47m"
)

ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_WARNING="⚠"
ICON_INFO=""
ICON_DOWNLOAD="↓"
ICON_GEAR="⚙ "

log() {
  local level="$1"
  local message="$2"
  local icon=""
  local color=""
  local timestamp
  timestamp=$(date "+%H:%M:%S")

  case "$level" in
  "success")
    icon="${ICON_SUCCESS}"
    color="${COLORS[green]}"
    ;;
  "warning")
    icon="${ICON_WARNING}"
    color="${COLORS[yellow]}"
    ;;
  "error")
    icon="${ICON_ERROR}"
    color="${COLORS[red]}"
    ;;
  "info")
    icon="${ICON_INFO}"
    color="${COLORS[blue]}"
    ;;
  "download")
    icon="${ICON_DOWNLOAD}"
    color="${COLORS[magenta]}"
    ;;
  *)
    icon=" "
    color="${COLORS[reset]}"
    ;;
  esac

  echo -e "$color$icon${COLORS[reset]} ${COLORS[dim]}[$timestamp]${COLORS[reset]} $message"
}

__need_sudo() {
  if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    log "error" "Please run as root: sudo -E dot"
    exit
  fi
  eval "$@"
}

__get_latest_release() {
  curl -s "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

__is_pkg_installed() {
  local name="$1"

  pacman -Q "$name" &>/dev/null
}

__is_program_installed() {
  local name="$1"

  command -v "$name" &>/dev/null
}

__install_appimage() {
  local url=$1
  local name=$2
  local filename

  filename=$(basename "$url" ".tar.gz")

  cd /tmp || exit 1
  wget -nv -q "$url" && log "success" "'$filename' downloaded." >/dev/null || return 1
  chmod +x "$filename"
  mv "$filename" "$HOME/.local/bin/$name" && log "success" "'$name' moved in $HOME/.local/bin/" || return 1
}

__install_package_release() {
  local url=$1
  local name=$2
  local filename

  filename=$(basename "$url")

  log "download" "Downloading $filename"
  cd /tmp || exit 1

  if [ -d "/tmp/$name" ]; then
    log "info" "Removing old $name directory."
    rm -rf "/tmp/$name"
  fi

  if [ -f "/tmp/$filename" ]; then
    log "info" "Removing old $filename file."
    rm "/tmp/$filename"
  fi

  wget -nv -q "$url" >/dev/null && log "success" "'$filename' downloaded." || return 1

  if [[ "$filename" == *.tar.gz ]]; then
    tar -xf "$filename" && log "success" "$filename extracted." || return 1
    filename=$(basename "$filename" ".tar.gz")
    if [ -d "/tmp/$filename" ]; then
      cd "/tmp/$filename" || exit 1
    fi
    rm -f "/tmp/$filename.tar.gz"
  elif [[ "$filename" == *.zip ]]; then
    unzip -oq "$filename" && log "success" "$filename extracted." || return 1
    filename=$(basename "$filename" ".zip")
    if [ -d "/tmp/$filename" ]; then
      cd "/tmp/$filename" || exit 1
    fi
    rm -f "/tmp/$filename.zip"
  elif [[ "$filename" == *.gz ]]; then
    gunzip -f "$filename" && log "success" "$filename extracted." || return 1
    filename=$(basename "$filename" ".gz")

    mv "$filename" "$name"
    rm -f "/tmp/$filename.gz"
  else
    mv "$filename" "$name"
    rm -f "/tmp/$filename"
  fi

  chmod +x "$name"
  mv "$name" "$HOME/.local/bin/$name" && log "success" "'$name' moved in $HOME/.local/bin/" || return 1
}

__install_zsh_plugin() {
  local url=$1
  local folder
  folder=$(echo "$url" | sed -r 's|.*/(.*)\.git$|\1|')

  local installation_folder="$HOME/.oh-my-zsh/custom/plugins/$folder"

  [ -d "$installation_folder" ] && rm -rf "$installation_folder"

  git clone "$url" "$installation_folder" && log "success" "$folder installed." || return 1
}

__install_package_arch() {
  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      sudo pacman -S --noconfirm --needed "$pkg" && log "success" "$pkg installed."
    fi
  done
}

__install_package_aur() {
  if ! command -v paru &>/dev/null; then
    source "$DOT_MANAGER_DIR/install/programs/aur.sh"
  fi

  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      paru -S --noconfirm --needed "$pkg" && log "success" "$pkg installed."
    fi
  done
}

__install_package_apt() {
  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 "$pkg" && log "success" "$pkg installed."
    fi
  done
}

__make_symlink() {
  local path="$1"
  local oldname="$2"
  local oldname_path

  [ -f "$path" ] && rm -f "$path"

  oldname_path=$(which "$oldname")

  ln -s "$oldname_path" "$path"
}

__git_dot() {
  /usr/bin/git --git-dir="$HOME/.cfg/" --work-tree="$HOME" "$@"
}

_HELPER_ALREADY_LOADED=1

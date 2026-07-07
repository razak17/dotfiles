#!/bin/env bash

if [ -n "$__HELPER_ALREADY_LOADED" ]; then
  return 0
fi

DOT_MANAGER_LOG="${DOT_MANAGER_CACHE_DIR:-$HOME/.cache/dot-manager}/last-run.log"
mkdir -p "$(dirname "$DOT_MANAGER_LOG")"

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
  echo -e "${COLORS[blue]}${ICON_GEAR}${DOT_STEP_PREFIX:+$DOT_STEP_PREFIX }${COLORS[bold]}$message${COLORS[reset]}"
}

print_separator() {
  line=$(printf ─%.0s $(seq 1 60))
  echo -e "\n${COLORS[dim]}${line}${COLORS[reset]}\n"
}

declare -A COLORS=(
  ["reset"]="\033[0m"
  ["bold"]="\033[1m"
  ["dim"]="\033[2m"

  ["red"]="\033[31m"
  ["green"]="\033[32m"
  ["yellow"]="\033[33m"
  ["blue"]="\033[34m"
  ["magenta"]="\033[35m"
)

ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_DOWNLOAD="↓"
ICON_GEAR="⚙ "

if [ ! -t 1 ]; then
  for k in "${!COLORS[@]}"; do COLORS[$k]=""; done
fi

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
  "error")
    icon="${ICON_ERROR}"
    color="${COLORS[red]}"
    ;;
  "info")
    icon="•"
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
  # ponytail: redirect follow instead of api.github.com, avoids the 60 req/hr unauthenticated limit
  basename "$(curl -sI -o /dev/null -w '%{redirect_url}' "https://github.com/$1/releases/latest")"
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

  if ! wget -nv "$url" >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to download $filename"
    return 1
  fi

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

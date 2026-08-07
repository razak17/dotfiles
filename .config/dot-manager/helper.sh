#!/bin/env bash

if [ -n "$__HELPER_ALREADY_LOADED" ]; then
  return 0
fi

DOT_MANAGER_GIT_DIR="${DOT_MANAGER_GIT_DIR:-$HOME/.dots/dotfiles}"
DOT_MANAGER_WORK_TREE="${DOT_MANAGER_WORK_TREE:-$HOME}"
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

__DOT_PRIVILEGE_RESOLVED=0
__DOT_PRIVILEGE_BIN=""
__DOT_PRIVILEGE_KIND=""

__effective_uid() {
  printf '%s\n' "${DOT_MANAGER_TEST_EUID:-${EUID:-$(id -u)}}"
}

__resolve_privilege_command() {
  local requested="${DOT_PRIVILEGE_CMD:-}"

  [ "$__DOT_PRIVILEGE_RESOLVED" -eq 0 ] || return 0

  if [ "$(__effective_uid)" -eq 0 ]; then
    __DOT_PRIVILEGE_RESOLVED=1
    return 0
  fi

  if [ -n "$requested" ]; then
    case "$requested" in
    doas | sudo) ;;
    *)
      log "error" "DOT_PRIVILEGE_CMD must be 'doas' or 'sudo'."
      return 1
      ;;
    esac

    if ! command -v "$requested" >/dev/null 2>&1; then
      log "error" "DOT_PRIVILEGE_CMD '$requested' is not available."
      return 1
    fi

    __DOT_PRIVILEGE_BIN=$(command -v "$requested")
    __DOT_PRIVILEGE_KIND="$requested"
  elif command -v doas >/dev/null 2>&1; then
    __DOT_PRIVILEGE_BIN=$(command -v doas)
    __DOT_PRIVILEGE_KIND=doas
  elif command -v sudo >/dev/null 2>&1; then
    __DOT_PRIVILEGE_BIN=$(command -v sudo)
    __DOT_PRIVILEGE_KIND=sudo
  else
    log "error" "Neither doas nor sudo is available for privileged commands."
    return 1
  fi

  __DOT_PRIVILEGE_RESOLVED=1
}

__as_root() {
  if [ "$(__effective_uid)" -eq 0 ]; then
    "$@"
    return
  fi

  __resolve_privilege_command || return 1
  "$__DOT_PRIVILEGE_BIN" "$@"
}

__as_user() {
  local username="$1"
  shift

  if [ "$(__effective_uid)" -eq 0 ]; then
    runuser -u "$username" -- "$@"
    return
  fi

  __resolve_privilege_command || return 1
  if [ "$__DOT_PRIVILEGE_KIND" = doas ]; then
    "$__DOT_PRIVILEGE_BIN" -u "$username" "$@"
  else
    "$__DOT_PRIVILEGE_BIN" -u "$username" -- "$@"
  fi
}

__authenticate() {
  __as_root true
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
  local failed=()
  local pkg

  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      if __as_root pacman -S --noconfirm --needed "$pkg"; then
        log "success" "$pkg installed."
      else
        log "error" "Failed to install $pkg."
        failed+=("$pkg")
      fi
    fi
  done

  if [ ${#failed[@]} -gt 0 ]; then
    log "error" "Package installation failed: ${failed[*]}"
    return 1
  fi
}

__install_package_aur() {
  local failed=()
  local paru_command=(paru)
  local pkg

  if ! command -v paru &>/dev/null; then
    log "error" "paru is required to install AUR packages."
    return 1
  fi

  if ! __resolve_privilege_command; then
    return 1
  fi
  if [ -n "$__DOT_PRIVILEGE_BIN" ]; then
    paru_command+=(--sudo "$__DOT_PRIVILEGE_BIN")
  fi

  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      if "${paru_command[@]}" -S --noconfirm --needed "$pkg"; then
        log "success" "$pkg installed."
      else
        log "error" "Failed to install $pkg."
        failed+=("$pkg")
      fi
    fi
  done

  if [ ${#failed[@]} -gt 0 ]; then
    log "error" "AUR package installation failed: ${failed[*]}"
    return 1
  fi
}

__install_package_apt() {
  for pkg in "$@"; do
    if __is_pkg_installed "$pkg"; then
      log "info" "$pkg already installed."
    else
      __as_root apt-get install -y -qq -o=Dpkg::Use-Pty=0 "$pkg" && log "success" "$pkg installed."
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
  /usr/bin/git \
    --git-dir="$DOT_MANAGER_GIT_DIR" \
    --work-tree="$DOT_MANAGER_WORK_TREE" \
    "$@"
}

__init_dot_submodules() {
  if [ ! -d "$DOT_MANAGER_GIT_DIR" ]; then
    log "error" "Dotfiles repository not found at $DOT_MANAGER_GIT_DIR."
    return 1
  fi

  if ! __git_dot show HEAD:.gitmodules >/dev/null 2>&1; then
    return 0
  fi

  log "info" "Synchronizing dotfiles submodules..."
  if ! /usr/bin/git \
    -C "$DOT_MANAGER_WORK_TREE" \
    --git-dir="$DOT_MANAGER_GIT_DIR" \
    --work-tree="$DOT_MANAGER_WORK_TREE" \
    -c core.bare=false \
    submodule sync --recursive >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to synchronize dotfiles submodules. (details: $DOT_MANAGER_LOG)"
    return 1
  fi

  log "info" "Installing dotfiles submodules..."
  if ! /usr/bin/git \
    -C "$DOT_MANAGER_WORK_TREE" \
    --git-dir="$DOT_MANAGER_GIT_DIR" \
    --work-tree="$DOT_MANAGER_WORK_TREE" \
    -c core.bare=false \
    submodule update --init --recursive >>"$DOT_MANAGER_LOG" 2>&1; then
    log "error" "Failed to install dotfiles submodules. (details: $DOT_MANAGER_LOG)"
    return 1
  fi
}

__HELPER_ALREADY_LOADED=1

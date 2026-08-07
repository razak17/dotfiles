#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
HELPER_PATH="$DOT_MANAGER_ROOT/helper.sh"

if ! DOT_MANAGER_CACHE_DIR="$TEST_ROOT/guard-cache" HELPER_PATH="$HELPER_PATH" \
  /usr/bin/bash -c '
    __HELPER_ALREADY_LOADED=""
    source "$HELPER_PATH"
    __as_root() { return 77; }
    source "$HELPER_PATH"
    __as_root
    [ "$?" -eq 77 ]
  '; then
  printf 'Sourcing helper.sh twice replaced existing helper functions\n' >&2
  exit 1
fi

DOT_MANAGER_CACHE_DIR="$TEST_ROOT/package-cache"
__HELPER_ALREADY_LOADED=""
source "$HELPER_PATH"

log() { return 0; }
__is_pkg_installed() { return 1; }
__as_root() {
  [ "${5:-}" != "broken-package" ]
}

if __install_package_arch broken-package healthy-package; then
  printf 'Arch package helper swallowed an earlier package failure\n' >&2
  exit 1
fi
if ! __install_package_arch healthy-package; then
  printf 'Arch package helper failed after successful installations\n' >&2
  exit 1
fi

__resolve_privilege_command() {
  __DOT_PRIVILEGE_BIN=/mock/doas
  __DOT_PRIVILEGE_KIND=doas
  __DOT_PRIVILEGE_RESOLVED=1
}

paru() {
  PARU_CALL_COUNT=$((PARU_CALL_COUNT + 1))
  PARU_LAST_ARGS="$*"
  if [ "${1:-}" != "--sudo" ] ||
    [ "${2:-}" != "/mock/doas" ] ||
    [ "${3:-}" != "--sudoloop=/usr/bin/true" ]; then
    return 98
  fi
  case " $* " in
  *" broken-package "*) return 1 ;;
  esac
  return 0
}

PARU_CALL_COUNT=0
PARU_LAST_ARGS=""
if __install_package_aur broken-package healthy-package; then
  printf 'AUR package helper swallowed an earlier package failure\n' >&2
  exit 1
fi
if [ "$PARU_CALL_COUNT" -ne 1 ]; then
  printf 'AUR package helper used %s Paru calls for one package batch\n' "$PARU_CALL_COUNT" >&2
  exit 1
fi

PARU_CALL_COUNT=0
PARU_LAST_ARGS=""
if ! __install_package_aur healthy-one healthy-two; then
  printf 'AUR package helper failed after successful installations\n' >&2
  exit 1
fi
if [ "$PARU_CALL_COUNT" -ne 1 ]; then
  printf 'AUR package helper used %s Paru calls for one package batch\n' "$PARU_CALL_COUNT" >&2
  exit 1
fi
expected='--sudo /mock/doas --sudoloop=/usr/bin/true -S --noconfirm --needed healthy-one healthy-two'
if [ "$PARU_LAST_ARGS" != "$expected" ]; then
  printf 'Unexpected Paru arguments: %s\n' "$PARU_LAST_ARGS" >&2
  exit 1
fi

unset -f paru
command() {
  if [ "${1:-}" = "-v" ] && [ "${2:-}" = "paru" ]; then
    return 1
  fi
  builtin command "$@"
}
if __install_package_aur example-package; then
  printf 'AUR package helper succeeded without paru\n' >&2
  exit 1
fi

printf 'Package helper tests passed\n'

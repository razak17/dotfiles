#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
AUR_PATH="$DOT_MANAGER_ROOT/install/programs/aur.sh"
HELPER_PATH="$DOT_MANAGER_ROOT/helper.sh"

run_failed_build() (
  DOT_MANAGER_DIR="$DOT_MANAGER_ROOT"
  DOT_MANAGER_CACHE_DIR="$TEST_ROOT/failure-cache"
  DOT_MANAGER_MOCK_LOG="$TEST_ROOT/failure-calls.log"
  export DOT_MANAGER_DIR DOT_MANAGER_CACHE_DIR DOT_MANAGER_MOCK_LOG

  __HELPER_ALREADY_LOADED=""
  source "$HELPER_PATH"
  __HELPER_ALREADY_LOADED=1

  __install_package_arch() { return 0; }
  __install_package_aur() {
    printf 'aur-essentials\n' >>"$DOT_MANAGER_MOCK_LOG"
    return 0
  }
  command() {
    if [ "${1:-}" = "-v" ] && [ "${2:-}" = "paru" ]; then
      return 1
    fi
    builtin command "$@"
  }
  git() { return 0; }
  cd() { return 0; }
  makepkg() {
    printf 'makepkg\n' >>"$DOT_MANAGER_MOCK_LOG"
    return 23
  }

  : >"$DOT_MANAGER_MOCK_LOG"
  set +e
  source "$AUR_PATH" >"$TEST_ROOT/failure-output" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    printf 'Failed paru build unexpectedly succeeded\n' >&2
    return 1
  fi
  if grep -q 'paru installed' "$TEST_ROOT/failure-output"; then
    printf 'Failed paru build was reported as successful\n' >&2
    return 1
  fi
  if grep -q 'aur-essentials' "$DOT_MANAGER_MOCK_LOG"; then
    printf 'AUR essentials ran after a failed paru build\n' >&2
    return 1
  fi
  [ "$(grep -c '^makepkg$' "$DOT_MANAGER_MOCK_LOG")" -eq 1 ]
)

run_missing_package_list() (
  DOT_MANAGER_DIR="$DOT_MANAGER_ROOT"
  DOT_MANAGER_CACHE_DIR="$TEST_ROOT/missing-package-cache"
  DOT_MANAGER_MOCK_LOG="$TEST_ROOT/missing-package-calls.log"
  export DOT_MANAGER_DIR DOT_MANAGER_CACHE_DIR DOT_MANAGER_MOCK_LOG

  __HELPER_ALREADY_LOADED=""
  source "$HELPER_PATH"
  __HELPER_ALREADY_LOADED=1

  __install_package_arch() { return 0; }
  __install_package_aur() {
    printf 'aur-essentials\n' >>"$DOT_MANAGER_MOCK_LOG"
  }
  __as_root() {
    printf 'root-install\n' >>"$DOT_MANAGER_MOCK_LOG"
  }
  command() {
    if [ "${1:-}" = "-v" ] && [ "${2:-}" = "paru" ]; then
      return 1
    fi
    builtin command "$@"
  }
  git() {
    mkdir -p "${3:-}"
  }
  makepkg() {
    case "${1:-}" in
    --noconfirm) return 0 ;;
    --packagelist) return 0 ;;
    *) return 99 ;;
    esac
  }

  : >"$DOT_MANAGER_MOCK_LOG"
  set +e
  source "$AUR_PATH" >"$TEST_ROOT/missing-package-output" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    printf 'Empty paru package list unexpectedly succeeded\n' >&2
    return 1
  fi
  grep -q 'produced no installable packages' "$TEST_ROOT/missing-package-output"
  if grep -Eq 'root-install|aur-essentials' "$DOT_MANAGER_MOCK_LOG"; then
    printf 'Installation continued without a built paru package\n' >&2
    return 1
  fi
)

run_successful_build() (
  local fixture_bin="$TEST_ROOT/success-bin"
  local build_root="$TEST_ROOT/paru-build"
  local mock_paru="$fixture_bin/paru"

  mkdir -p "$fixture_bin"

  DOT_MANAGER_DIR="$DOT_MANAGER_ROOT"
  DOT_MANAGER_CACHE_DIR="$TEST_ROOT/success-cache"
  DOT_MANAGER_MOCK_LOG="$TEST_ROOT/success-calls.log"
  MOCK_PARU="$mock_paru"
  BUILD_ROOT="$build_root"
  export DOT_MANAGER_DIR DOT_MANAGER_CACHE_DIR DOT_MANAGER_MOCK_LOG MOCK_PARU BUILD_ROOT

  __HELPER_ALREADY_LOADED=""
  source "$HELPER_PATH"
  __HELPER_ALREADY_LOADED=1

  __install_package_arch() {
    printf 'arch:' >>"$DOT_MANAGER_MOCK_LOG"
    printf ' <%s>' "$@" >>"$DOT_MANAGER_MOCK_LOG"
    printf '\n' >>"$DOT_MANAGER_MOCK_LOG"
  }
  __install_package_aur() {
    printf 'aur-essentials\n' >>"$DOT_MANAGER_MOCK_LOG"
  }
  __as_root() {
    printf 'root:' >>"$DOT_MANAGER_MOCK_LOG"
    printf ' <%s>' "$@" >>"$DOT_MANAGER_MOCK_LOG"
    printf '\n' >>"$DOT_MANAGER_MOCK_LOG"
    printf '#!/bin/sh\nexit 0\n' >"$MOCK_PARU"
    chmod +x "$MOCK_PARU"
  }
  command() {
    if [ "${1:-}" = "-v" ] && [ "${2:-}" = "paru" ]; then
      [ -x "$MOCK_PARU" ] || return 1
      printf '%s\n' "$MOCK_PARU"
      return 0
    fi
    builtin command "$@"
  }
  mktemp() {
    mkdir -p "$BUILD_ROOT"
    printf '%s\n' "$BUILD_ROOT"
  }
  git() {
    printf 'git:' >>"$DOT_MANAGER_MOCK_LOG"
    printf ' <%s>' "$@" >>"$DOT_MANAGER_MOCK_LOG"
    printf '\n' >>"$DOT_MANAGER_MOCK_LOG"
    case "${3:-}" in
    "$BUILD_ROOT"/*) mkdir -p "$3" ;;
    *) return 98 ;;
    esac
  }
  cd() {
    case "${1:-}" in
    "$BUILD_ROOT"/*) builtin cd "$1" ;;
    *) return 97 ;;
    esac
  }
  makepkg() {
    printf 'makepkg:' >>"$DOT_MANAGER_MOCK_LOG"
    printf ' <%s>' "$@" >>"$DOT_MANAGER_MOCK_LOG"
    printf '\n' >>"$DOT_MANAGER_MOCK_LOG"
    case "${1:-}" in
    --noconfirm)
      : >"$BUILD_ROOT/paru/paru-2.1.0-2-x86_64.pkg.tar.zst"
      ;;
    --packagelist)
      printf '%s\n' "$BUILD_ROOT/paru/paru-2.1.0-2-x86_64.pkg.tar.zst"
      ;;
    *) return 99 ;;
    esac
  }

  : >"$DOT_MANAGER_MOCK_LOG"
  source "$AUR_PATH" >"$TEST_ROOT/success-output" 2>&1

  grep -q '^arch: <git> <base-devel> <rust>$' "$DOT_MANAGER_MOCK_LOG"
  grep -q "^git: <clone> <https://aur.archlinux.org/paru.git> <$BUILD_ROOT/paru>$" "$DOT_MANAGER_MOCK_LOG"
  grep -q '^makepkg: <--noconfirm>$' "$DOT_MANAGER_MOCK_LOG"
  grep -q '^makepkg: <--packagelist>$' "$DOT_MANAGER_MOCK_LOG"
  grep -q "^root: <pacman> <-U> <--noconfirm> <--needed> <$BUILD_ROOT/paru/paru-2.1.0-2-x86_64.pkg.tar.zst>$" "$DOT_MANAGER_MOCK_LOG"
  grep -q '^aur-essentials$' "$DOT_MANAGER_MOCK_LOG"
  grep -q 'paru installed' "$TEST_ROOT/success-output"
  [ ! -e "$BUILD_ROOT" ]
)

run_failed_build
run_missing_package_list
run_successful_build

printf 'AUR tests passed\n'

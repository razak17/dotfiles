#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

HELPER_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/helper.sh

make_support_path() {
  local directory=$1
  mkdir -p "$directory"
  for command in date dirname id mkdir runuser; do
    ln -s "$(command -v "$command")" "$directory/$command"
  done
}

make_mock() {
  local directory=$1
  local name=$2
  cat >"$directory/$name" <<'MOCK'
#!/bin/sh
printf '%s:' "${0##*/}" >>"$DOT_MANAGER_MOCK_LOG"
printf ' <%s>' "$@" >>"$DOT_MANAGER_MOCK_LOG"
printf '\n' >>"$DOT_MANAGER_MOCK_LOG"
MOCK
  chmod +x "$directory/$name"
}

run_helper() {
  local path=$1
  local command=$2
  shift 2

  env \
    PATH="$path" \
    DOT_MANAGER_CACHE_DIR="$TEST_ROOT/cache" \
    DOT_MANAGER_MOCK_LOG="$TEST_ROOT/calls.log" \
    HELPER_PATH="$HELPER_PATH" \
    TEST_COMMAND="$command" \
    "$@" \
    /usr/bin/bash -c 'source "$HELPER_PATH"; eval "$TEST_COMMAND"'
}

assert_last_call() {
  local expected=$1
  local actual
  actual=$(tail -n 1 "$TEST_ROOT/calls.log")
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected: %s\nActual:   %s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

both="$TEST_ROOT/both"
make_support_path "$both"
make_mock "$both" doas
make_mock "$both" sudo

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__as_root pacman -S example'
assert_last_call 'doas: <pacman> <-S> <example>'

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__as_root pacman -S example' DOT_PRIVILEGE_CMD=sudo
assert_last_call 'sudo: <pacman> <-S> <example>'

sudo_only="$TEST_ROOT/sudo-only"
make_support_path "$sudo_only"
make_mock "$sudo_only" sudo

: >"$TEST_ROOT/calls.log"
run_helper "$sudo_only" '__as_root pacman -S example'
assert_last_call 'sudo: <pacman> <-S> <example>'

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__authenticate'
assert_last_call 'doas: <true>'

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__as_user postgres initdb -D /var/lib/postgres/data'
assert_last_call 'doas: <-u> <postgres> <initdb> <-D> </var/lib/postgres/data>'

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__as_user postgres initdb -D /var/lib/postgres/data' DOT_PRIVILEGE_CMD=sudo
assert_last_call 'sudo: <-u> <postgres> <--> <initdb> <-D> </var/lib/postgres/data>'

: >"$TEST_ROOT/calls.log"
run_helper "$both" '__as_root printf root-bypass' DOT_MANAGER_TEST_EUID=0 >"$TEST_ROOT/root.out"
grep -q 'root-bypass' "$TEST_ROOT/root.out"
[[ ! -s "$TEST_ROOT/calls.log" ]]

if run_helper "$both" '__as_root true' DOT_PRIVILEGE_CMD=missing >"$TEST_ROOT/error.out" 2>&1; then
  printf 'Invalid override unexpectedly succeeded\n' >&2
  exit 1
fi
grep -q "DOT_PRIVILEGE_CMD must be 'doas' or 'sudo'" "$TEST_ROOT/error.out"

none="$TEST_ROOT/none"
make_support_path "$none"
if run_helper "$none" '__as_root true' >"$TEST_ROOT/error.out" 2>&1; then
  printf 'Missing escalator unexpectedly succeeded\n' >&2
  exit 1
fi
grep -q 'Neither doas nor sudo is available' "$TEST_ROOT/error.out"

printf 'Privilege tests passed\n'

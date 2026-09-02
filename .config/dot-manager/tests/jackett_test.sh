#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
INSTALLER="$DOT_MANAGER_ROOT/install/programs/jackett.sh"
INIT_SCRIPT="$DOT_MANAGER_ROOT/install/services/jackett"

grep -q 'export HOME="/var/lib/jackett"' "$INIT_SCRIPT"
grep -q 'start_stop_daemon_args="--user jackett --group jackett' "$INIT_SCRIPT"
grep -q 'command="/opt/Jackett/jackett"' "$INIT_SCRIPT"

run_scenario() (
  local scenario="$1"
  local expected_result="$2"
  local fail_call="${3:-}"
  local scenario_root="$TEST_ROOT/$scenario"
  local call_log="$scenario_root/calls"

  mkdir -p "$scenario_root"
  : >"$call_log"

  DOT_MANAGER_DIR="$DOT_MANAGER_ROOT"
  DOT_MANAGER_CACHE_DIR="$scenario_root/cache"
  JACKETT_INSTALL_DIR="$scenario_root/opt/Jackett"
  JACKETT_INIT_TARGET="$scenario_root/init.d/jackett"
  __HELPER_ALREADY_LOADED=""
  source "$DOT_MANAGER_ROOT/helper.sh"

  log() { return 0; }
  print_step() { return 0; }

  getent() {
    [ "$scenario" != "fresh" ]
  }

  id() {
    [ "$scenario" != "fresh" ]
  }

  wget() {
    printf 'wget %s\n' "$*" >>"$call_log"
    return 0
  }

  __as_root() {
    printf '%s\n' "$*" >>"$call_log"

    if [ "$*" = "rc-service jackett status" ]; then
      [ "$scenario" = "running" ]
      return
    fi
    if [ -n "$fail_call" ] && [ "$*" = "$fail_call" ]; then
      return 1
    fi
    return 0
  }

  if [ "$scenario" != "fresh" ]; then
    mkdir -p "$JACKETT_INSTALL_DIR"
    : >"$JACKETT_INSTALL_DIR/jackett"
    chmod +x "$JACKETT_INSTALL_DIR/jackett"
  fi

  if [ "$expected_result" = "success" ]; then
    source "$INSTALLER" >/dev/null
  elif source "$INSTALLER" >/dev/null; then
    printf 'Jackett installer unexpectedly succeeded in %s scenario\n' "$scenario" >&2
    return 1
  fi
)

run_scenario fresh success
fresh_calls="$TEST_ROOT/fresh/calls"
grep -q '^groupadd --system jackett$' "$fresh_calls"
grep -q '^useradd --system --gid jackett --home-dir /var/lib/jackett --create-home --shell /usr/bin/nologin jackett$' "$fresh_calls"
grep -q '^wget -O /tmp/jackett\.' "$fresh_calls"
grep -q '^tar -xzf /tmp/jackett\.' "$fresh_calls"
grep -q '^rc-update add jackett default$' "$fresh_calls"
grep -q '^rc-service jackett start$' "$fresh_calls"

run_scenario existing success
existing_calls="$TEST_ROOT/existing/calls"
if grep -q '^wget ' "$existing_calls"; then
  printf 'Existing Jackett installation was downloaded again\n' >&2
  exit 1
fi
grep -q '^install -d -o jackett -g jackett -m 0755 /var/lib/jackett$' "$existing_calls"
grep -q '^chown -R jackett:jackett ' "$existing_calls"
grep -q '^install -m 0755 .*install/services/jackett .*init.d/jackett$' "$existing_calls"
grep -q '^rc-service jackett start$' "$existing_calls"

run_scenario running success
grep -q '^rc-service jackett restart$' "$TEST_ROOT/running/calls"

run_scenario start_failure failure 'rc-service jackett start'

printf 'Jackett installer tests passed\n'

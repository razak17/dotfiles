#!/usr/bin/env bash

set -euo pipefail

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
INSTALLER="$DOT_MANAGER_ROOT/install/programs/steam2_downloader.sh"

run_scenario() (
  local scenario="$1"
  local machine="$2"
  local action="$3"
  local expected_result="$4"
  local scenario_root="$TEST_ROOT/$scenario"
  local call_log="$scenario_root/calls"

  mkdir -p "$scenario_root/home"
  : >"$call_log"

  export HOME="$scenario_root/home"
  export DOT_MANAGER_DIR="$DOT_MANAGER_ROOT"
  export DOT_MANAGER_CACHE_DIR="$scenario_root/cache"
  export __HELPER_ALREADY_LOADED=""
  export STEAM2_DOWNLOADER_MACHINE="$machine"
  export STEAM2_DOWNLOADER_INSTALL_DIR="$scenario_root/install"
  export STEAM2_DOWNLOADER_BIN_LINK="$scenario_root/bin/steam2browser"

  wget() {
    local output=""

    printf 'wget %s\n' "$*" >>"$call_log"
    while [ $# -gt 0 ]; do
      if [ "$1" = "-O" ]; then
        output="$2"
        break
      fi
      shift
    done
    : >"$output"
  }

  unzip() {
    local destination=""

    printf 'unzip %s\n' "$*" >>"$call_log"
    while [ $# -gt 0 ]; do
      if [ "$1" = "-d" ]; then
        destination="$2"
        break
      fi
      shift
    done
    mkdir -p "$destination"
    printf '#!/usr/bin/env bash\n' >"$destination/steam2browser"
    printf 'managed assembly\n' >"$destination/steam2browser.dll"
    printf 'runtime library\n' >"$destination/libhostfxr.so"
  }

  if [ "$scenario" = "existing" ] || [ "$scenario" = "reinstall" ]; then
    mkdir -p "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2info"
    printf 'old binary\n' >"$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser"
    printf 'old assembly\n' >"$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser.dll"
    printf 'old runtime library\n' >"$STEAM2_DOWNLOADER_INSTALL_DIR/libhostfxr.so"
    printf 'keep me\n' >"$STEAM2_DOWNLOADER_INSTALL_DIR/steam2info/catalog"
    chmod +x "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser"
  elif [ "$scenario" = "partial" ]; then
    mkdir -p "$STEAM2_DOWNLOADER_INSTALL_DIR"
    printf 'partial binary\n' >"$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser"
    chmod +x "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser"
  fi

  if [ "$expected_result" = "success" ]; then
    source "$INSTALLER" "$action" >/dev/null
  elif source "$INSTALLER" "$action" >/dev/null; then
    printf 'Steam2 Downloader installer unexpectedly succeeded in %s scenario\n' "$scenario" >&2
    return 1
  fi

  if [ "$expected_result" = "success" ]; then
    [ -x "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser" ]
    [ -f "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser.dll" ]
    [ -f "$STEAM2_DOWNLOADER_INSTALL_DIR/libhostfxr.so" ]
    [ "$(readlink "$STEAM2_DOWNLOADER_BIN_LINK")" = "$STEAM2_DOWNLOADER_INSTALL_DIR/steam2browser" ]
  fi
)

run_scenario x64 x86_64 install success
grep -q 'steam2browser-linux-x64.zip' "$TEST_ROOT/x64/calls"

run_scenario arm64 aarch64 install success
grep -q 'steam2browser-linux-arm64.zip' "$TEST_ROOT/arm64/calls"

run_scenario existing x86_64 install success
if grep -q '^wget ' "$TEST_ROOT/existing/calls"; then
  printf 'Existing Steam2 Downloader installation was downloaded again\n' >&2
  exit 1
fi

run_scenario partial x86_64 install success
grep -q '^wget ' "$TEST_ROOT/partial/calls"

run_scenario reinstall x86_64 reinstall success
grep -q '^keep me$' "$TEST_ROOT/reinstall/install/steam2info/catalog"
grep -q '^#!/usr/bin/env bash$' "$TEST_ROOT/reinstall/install/steam2browser"

run_scenario unsupported riscv64 install failure
if grep -q '^wget ' "$TEST_ROOT/unsupported/calls"; then
  printf 'Unsupported architecture triggered a download\n' >&2
  exit 1
fi

printf 'Steam2 Downloader tests passed\n'

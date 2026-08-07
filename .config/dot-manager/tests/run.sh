#!/usr/bin/env bash

set -euo pipefail

DOT_MANAGER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

"$DOT_MANAGER_ROOT/tests/aur_test.sh"
"$DOT_MANAGER_ROOT/tests/package_helper_test.sh"
"$DOT_MANAGER_ROOT/tests/privilege_test.sh"
"$DOT_MANAGER_ROOT/tests/shell_test.sh"
"$DOT_MANAGER_ROOT/tests/submodule_test.sh"
"$DOT_MANAGER_ROOT/tests/uninstall_test.sh"

while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find "$DOT_MANAGER_ROOT" -type f -name '*.sh' -print0)

if rg -n --glob '*.sh' '(^|[;&|][[:space:]]*)sudo[[:space:]]' "$DOT_MANAGER_ROOT"; then
  printf 'Direct sudo invocation found outside the privilege helper\n' >&2
  exit 1
fi

grep -q -- '--bare --branch doas' "$DOT_MANAGER_ROOT/first_install.sh"

printf 'All dot-manager tests passed\n'

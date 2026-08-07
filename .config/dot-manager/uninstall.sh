#!/usr/bin/env bash

dot_uninstall_error() {
  printf 'ERROR: %s\n' "$*" >&2
  return 1
}

dot_uninstall() {
  local dry_run=0
  local git_dir="${DOT_MANAGER_GIT_DIR:-$HOME/.dots/dotfiles}"
  local work_tree="${DOT_MANAGER_WORK_TREE:-$HOME}"
  local launcher="$HOME/.local/bin/dot"
  local git_dir_relative=""
  local launcher_relative=""
  local status_output record metadata object_type relative_path
  local submodule_root submodule_file answer target parent
  local -a targets=()
  local -a submodules=()
  local -A seen_targets=()

  if [ "$#" -gt 1 ]; then
    dot_uninstall_error "Usage: dot uninstall [--dry-run]"
    return 1
  fi
  if [ "$#" -eq 1 ]; then
    if [ "$1" != "--dry-run" ]; then
      dot_uninstall_error "Usage: dot uninstall [--dry-run]"
      return 1
    fi
    dry_run=1
  fi

  if [ ! -d "$git_dir" ]; then
    dot_uninstall_error "Bare repository not found: $git_dir"
    return 1
  fi
  if [ ! -d "$work_tree" ]; then
    dot_uninstall_error "Work tree not found: $work_tree"
    return 1
  fi

  git_dir=$(cd "$git_dir" && pwd -P) || return 1
  work_tree=$(cd "$work_tree" && pwd -P) || return 1

  if ! git --git-dir="$git_dir" rev-parse --verify HEAD >/dev/null 2>&1; then
    dot_uninstall_error "The bare repository has no valid HEAD."
    return 1
  fi

  case "$git_dir" in
  "$work_tree"/*) git_dir_relative=${git_dir#"$work_tree"/} ;;
  esac
  case "$launcher" in
  "$work_tree"/*) launcher_relative=${launcher#"$work_tree"/} ;;
  esac

  validate_relative_path() {
    local path=$1
    local remaining component current="$work_tree"

    if [ -z "$path" ] || [ "$path" = "." ] || [[ "$path" = /* ]]; then
      dot_uninstall_error "Unsafe tracked path: $path"
      return 1
    fi
    case "/$path/" in
    *"/../"*)
      dot_uninstall_error "Unsafe tracked path: $path"
      return 1
      ;;
    esac

    remaining=$path
    while [[ "$remaining" = */* ]]; do
      component=${remaining%%/*}
      remaining=${remaining#*/}
      if [ -z "$component" ]; then
        dot_uninstall_error "Unsafe tracked path: $path"
        return 1
      fi
      current="$current/$component"
      if [ -L "$current" ]; then
        dot_uninstall_error "Refusing path with a symlinked parent: $path"
        return 1
      fi
    done
  }

  add_target() {
    local path=$1

    validate_relative_path "$path" || return 1
    if [ -n "$git_dir_relative" ] &&
      { [ "$path" = "$git_dir_relative" ] || [[ "$path" = "$git_dir_relative"/* ]]; }; then
      return 0
    fi
    if [ -n "$launcher_relative" ] && [ "$path" = "$launcher_relative" ]; then
      return 0
    fi
    if [ -z "${seen_targets[$path]+present}" ]; then
      targets+=("$path")
      seen_targets[$path]=1
    fi
  }

  status_output=$(git --git-dir="$git_dir" --work-tree="$work_tree" \
    status --porcelain --untracked-files=no --ignore-submodules=untracked) || return 1
  if [ -n "$status_output" ]; then
    dot_uninstall_error "Refusing to remove tracked files while tracked changes exist."
    printf '%s\n' "$status_output" >&2
    return 1
  fi

  while IFS= read -r -d '' record; do
    metadata=${record%%$'\t'*}
    relative_path=${record#*$'\t'}
    object_type=${metadata#* }
    object_type=${object_type%% *}
    case "$object_type" in
    blob) add_target "$relative_path" || return 1 ;;
    commit)
      validate_relative_path "$relative_path" || return 1
      submodules+=("$relative_path")
      ;;
    esac
  done < <(git --git-dir="$git_dir" ls-tree -rz --full-tree HEAD)

  for relative_path in "${submodules[@]}"; do
    submodule_root="$work_tree/$relative_path"
    if [ ! -d "$submodule_root" ] ||
      ! git -C "$submodule_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      continue
    fi

    status_output=$(git -C "$submodule_root" status --porcelain --untracked-files=no) || return 1
    if [ -n "$status_output" ]; then
      dot_uninstall_error "Refusing to remove tracked files from dirty submodule: $relative_path"
      printf '%s\n' "$status_output" >&2
      return 1
    fi

    while IFS= read -r -d '' submodule_file; do
      add_target "$relative_path/$submodule_file" || return 1
    done < <(git -C "$submodule_root" ls-files -z)
  done

  printf 'Tracked targets: %d\n' "${#targets[@]}"
  for relative_path in "${targets[@]}"; do
    if [ "$dry_run" -eq 1 ]; then
      printf 'Would remove: %s\n' "$relative_path"
    else
      printf 'Remove: %s\n' "$relative_path"
    fi
  done

  if [ "$dry_run" -eq 1 ]; then
    printf 'Dry run only; nothing was removed.\n'
    return 0
  fi

  printf '\nType exactly: REMOVE %d TRACKED FILES\n> ' "${#targets[@]}"
  IFS= read -r answer
  if [ "$answer" != "REMOVE ${#targets[@]} TRACKED FILES" ]; then
    dot_uninstall_error "Confirmation did not match; nothing was removed."
    return 1
  fi

  cd "$work_tree" || return 1
  for relative_path in "${targets[@]}"; do
    validate_relative_path "$relative_path" || return 1
    target="$work_tree/$relative_path"
    if [ -f "$target" ] || [ -L "$target" ]; then
      rm -f -- "$target" || return 1
    elif [ -e "$target" ]; then
      dot_uninstall_error "Tracked target is not a file or symlink: $relative_path"
      return 1
    fi

    if [[ "$relative_path" = */* ]]; then
      parent=${relative_path%/*}
      while [ -n "$parent" ] && [ "$parent" != "." ]; do
        rmdir -- "$work_tree/$parent" 2>/dev/null || break
        if [[ "$parent" = */* ]]; then
          parent=${parent%/*}
        else
          break
        fi
      done
    fi
  done

  printf '\nTracked files removed. The repository and launcher were retained.\n'
  printf 'Restore with:\n'
  printf 'git --git-dir=%q --work-tree=%q checkout-index --all --force\n' \
    "$git_dir" "$work_tree"
  if [ "${#submodules[@]}" -gt 0 ]; then
    printf 'Then restore submodules with:\n'
    printf 'git -C %q --git-dir=%q --work-tree=%q -c core.bare=false submodule update --init --recursive --force\n' \
      "$work_tree" "$git_dir" "$work_tree"
  fi
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  dot_uninstall "$@"
fi

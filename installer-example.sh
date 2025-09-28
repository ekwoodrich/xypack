#!/bin/bash
# Helper script for installing, launching, and maintaining Zellij presets; see README.md for details.

XY_PACKAGE_NAME="zel"
XY_PACKAGE_DESCRIPTION="Helper script for installing, launching, and maintaining Zellij presets"
XY_PACKAGE_VERSION="1.0.0"
XY_PACKAGE_DATE="2025-09-28T00:00:00Z"
XY_PREFIX="xy_"
XY_PACKAGE_OUT="../../zip/"

XY_THIN_COLS=100

ZEL_DOWNLOAD_URL="https://zellij.dev/launch"
ZEL_INSTALL_PATH="/usr/local/bin"
ZEL_BINARY_PATH="${ZEL_INSTALL_PATH}/zellij"
ZEL_SCRIPT_SYMLINK="${ZEL_INSTALL_PATH}/zel"

ZEL_CONFIG_DIR_PATH="/root/.config/zellij/"
ZEL_CONFIG_PREFIX_DEFAULT="/root/.config/zellij/"
ZEL_CONFIG_KDL="${ZEL_CONFIG_DIR_PATH}zel-config.kdl"
ZEL_CONFIG_THIN_PATH="${ZEL_CONFIG_DIR_PATH}zel-config-thin.kdl"
ZEL_CONFIG_THIN_KDL="$ZEL_CONFIG_THIN_PATH"

ZEL_SESSION_FULL="zel"
ZEL_SESSION_THIN="zel-thin"

ZEL_SESSION="$ZEL_SESSION_FULL"
ZEL_CONFIG_PATH="$ZEL_CONFIG_KDL"

COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"
COLOR_LIGHT_BLUE="\033[94m"
COLOR_WHITE="\033[97m"
COLOR_LIGHT_GRAY="\033[37m"
COLOR_GRAY="\033[90m"
COLOR_MAGENTA="\033[95m"
COLOR_CYAN="\033[96m"
COLOR_LABEL="\033[30;47m"
COLOR_HEADER="\033[30;47m"
COLOR_RESET="\033[0m"

print_usage() {
  echo
  printf '%bUsage: ./zel.sh [command] [options]%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--fix-path] [--skip-download] [--use-zel-default]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[92minstall${COLOR_RESET}"
  printf '      %bDownload the Zellij binary (unless skipped), copy configs, and manage symlinks.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "${COLOR_YELLOW}download${COLOR_RESET}"
  printf '      %bFetch the Zellij binary and place it in the install path.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--keep-zellij]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "${COLOR_RED}uninstall${COLOR_RESET}"
  printf '      %bRemove the configs, script symlink, and optionally the installed binary.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--fix-path]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[37mupdate${COLOR_RESET}"
  printf '      %bUpdate only the .kdl config files, overwriting existing ones.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[37mimport${COLOR_RESET}"
  printf '      %bImport .kdl config files from installed location, backing up existing files.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--show-diff] [--list]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[37mcompare${COLOR_RESET}"
  printf '      %bCompare .kdl config files between installed location and zel directory.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '      %bUse --show-diff to display actual file differences.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '      %bUse --list to show all files regardless of differences.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--reset] [cols]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "respond"
  printf '      %bDetect terminal width (or use cols) and launch the full or thin layout.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '      %bUse --reset to clear sessions first (not with --dry-run).%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--reset] [cols]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "adapt | fit"
  printf '      %bAliases for respond with the same options.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--full-only|--thin-only]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "reset"
  printf '      %bDelete the full and/or thin Zellij sessions before launching.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "thin"
  printf '      %bLaunch Zellij with the bundled thin preset.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "full"
  printf '      %bLaunch Zellij with the bundled full preset.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--dry-run] [--ver VERSION] [--maj|--min|--patch]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "${COLOR_WHITE}package${COLOR_RESET}"
  printf '      %bCreate a versioned zip package of the zel directory, excluding existing .zip files.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '      %bUse --ver to set specific version, or --maj/--min/--patch to increment (default: patch).%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b [--only]\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[37mversion${COLOR_RESET}"
  printf '      %bShow package name, description, and version. Use --only to show just the version.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '  %b %b\n' \
    "${COLOR_LABEL}zel.sh${COLOR_RESET}" "help"
  printf '      %bShow this help message.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '%bNo command attaches to the default session or starts it with the main config.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
  printf '%bUse --reset with no command to delete sessions before attaching.%b\n' "$COLOR_GRAY" "$COLOR_RESET"
}

print_header() {
  local command_label="$1"
  local description="$2"
  local separator
  local width=${#description}
  local cmd_width=${#command_label}
  if (( cmd_width > width )); then
    width=$cmd_width
  fi
  if (( width == 0 )); then
    width=20
  fi
  separator=$(create_separator "$width")
  local base_label="${command_label%% *}"
  local remainder=""
  if [[ "$command_label" == *" "* ]]; then
    remainder="${command_label#* }"
  fi
  echo
  if [[ -n "$remainder" ]]; then
    local color="$COLOR_GREEN"
    if [[ "$remainder" == install ]]; then
      color="\033[92m"
    elif [[ "$remainder" == update ]]; then
      color="\033[37m"
    elif [[ "$remainder" == download ]]; then
      color="$COLOR_YELLOW"
    elif [[ "$remainder" == reset ]]; then
      color="\033[37m"
    elif [[ "$remainder" == uninstall ]]; then
      color="$COLOR_RED"
    fi
    printf " %b %b\n" "${COLOR_LABEL}${base_label}${COLOR_RESET}" "${color}${remainder}${COLOR_RESET}"
  else
    printf " %b\n" "${COLOR_LABEL}${base_label}${COLOR_RESET}"
  fi
  printf "\n"
  if [[ -n "$description" ]]; then
    printf " %b%s%b\n" "$COLOR_LIGHT_GRAY" "$description" "$COLOR_RESET"
  fi
  printf "\n"
  printf "%s\n\n" "$separator"
}

print_tree_structure() {
  local source_dir="$1"
  local target_root="$2"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$source_dir" "$target_root" <<'PY'
import os
import sys

source_dir = os.path.abspath(sys.argv[1])
target_root = sys.argv[2]

root_label = target_root.rstrip('/') + '/'
print(f"  {root_label}")

def emit(path, prefix):
    try:
        entries = list(os.scandir(path))
    except FileNotFoundError:
        return
    entries.sort(key=lambda entry: (not entry.is_dir(follow_symlinks=False), entry.name.lower()))
    total = len(entries)
    for index, entry in enumerate(entries):
        connector = '└── ' if index == total - 1 else '├── '
        suffix = '/' if entry.is_dir(follow_symlinks=False) else ''
        print(f"  {prefix}{connector}{entry.name}{suffix}")
        if entry.is_dir(follow_symlinks=False):
            extension = '    ' if index == total - 1 else '│   '
            emit(entry.path, prefix + extension)

emit(source_dir, '')
PY
  else
    echo "  ${target_root%/}/"
    find "$source_dir" -mindepth 1 -print | sort | while IFS= read -r path; do
      local rel
      rel="${path#"$source_dir/"}"
      echo "  └── $rel"
    done
  fi
}

detect_terminal_width() {
  local cols
  if cols=$(tput cols 2>/dev/null); then
    printf '%s' "$cols"
    return 0
  fi
  if cols=$(stty size 2>/dev/null | awk '{print $2}' 2>/dev/null); then
    printf '%s' "$cols"
    return 0
  fi
  if [[ -n "$COLUMNS" ]]; then
    printf '%s' "$COLUMNS"
    return 0
  fi
  printf '80'
  return 1
}

session_exists() {
  local session_name="$1"
  zellij list-sessions 2>/dev/null | grep -q "^$session_name$"
}

launch_zellij_session() {
  local session_name="$1"
  local config_path="$2"

  if session_exists "$session_name"; then
    exec zellij attach "$session_name"
  else
    exec zellij --config "$config_path" -s "$session_name"
  fi
}

create_separator() {
  local width="$1"
  local separator

  if [[ -z "$width" ]]; then
    width=20
  fi
  if (( width > 72 )); then
    width=72
  fi

  separator=$(printf '%*s' "$width" '')
  separator=${separator// /─}
  printf ' %b%s%b' "$COLOR_GRAY" "$separator" "$COLOR_RESET"
}

parse_version() {
  local version="$1"
  if [[ "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
  else
    echo "0 0 0"
  fi
}

increment_version() {
  local version="$1"
  local component="$2"
  local version_parts
  read -r major minor patch <<< "$(parse_version "$version")"

  case "$component" in
    major)
      ((major++))
      minor=0
      patch=0
      ;;
    minor)
      ((minor++))
      patch=0
      ;;
    patch)
      ((patch++))
      ;;
    *)
      echo "Invalid version component: $component" >&2
      return 1
      ;;
  esac

  echo "${major}.${minor}.${patch}"
}

update_version_in_script() {
  local new_version="$1"
  local script_path="$2"
  local new_date="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  sed -i "s/^XY_PACKAGE_VERSION=\".*\"/XY_PACKAGE_VERSION=\"$new_version\"/" "$script_path"
  sed -i "s/^XY_PACKAGE_DATE=\".*\"/XY_PACKAGE_DATE=\"$new_date\"/" "$script_path"
}

run_respond() {
  local dry_run="${1:-false}"
  local manual_cols="${2:-}"
  local cols
  local threshold

  if [[ -n "$manual_cols" ]]; then
    if [[ "$manual_cols" =~ ^[0-9]+$ ]]; then
      threshold="$manual_cols"
    else
      echo "Invalid column override: $manual_cols" >&2
      exit 1
    fi
    cols=$(detect_terminal_width)
    if ! [[ "$cols" =~ ^[0-9]+$ ]]; then
      cols=80
    fi
  else
    cols=$(detect_terminal_width)
    if ! [[ "$cols" =~ ^[0-9]+$ ]]; then
      cols=80
    fi
    threshold="$XY_THIN_COLS"
  fi
  local layout_label="[full]"
  local color="$COLOR_GREEN"
  local -a target=("$0")
  local config_path="$ZEL_CONFIG_KDL"
  if (( cols < threshold )); then
    layout_label="[thin]"
    color="$COLOR_YELLOW"
    target=("$0" "thin")
    config_path="${ZEL_CONFIG_THIN_KDL:-$ZEL_CONFIG_THIN_PATH}"
  fi
  local highlight_color
  if (( cols < threshold )); then
    highlight_color="$COLOR_LIGHT_BLUE"
  else
    highlight_color="$COLOR_MAGENTA"
  fi
  printf '\n%bTerminal reports width of %b[%s]%b%b cols, threshold is %b[%s]%b%b cols.%b\n\n' "$COLOR_GRAY" "$highlight_color" "$cols" "$COLOR_RESET" "$COLOR_GRAY" "$COLOR_WHITE" "$threshold" "$COLOR_RESET" "$COLOR_GRAY" "$COLOR_RESET"
  printf '%bUsing %s zellij layout...%b\n\n' "$highlight_color" "$layout_label" "$COLOR_RESET"
  printf '%bFrom: %b%s%b\n\n' "$COLOR_GRAY" "$COLOR_WHITE" "$config_path" "$COLOR_RESET"
  if [[ "$dry_run" == true ]]; then
    return 0
  fi
  if [[ "${target[1]}" == "thin" ]]; then
    launch_zellij_session "$ZEL_SESSION_THIN" "${ZEL_CONFIG_THIN_KDL:-$ZEL_CONFIG_THIN_PATH}"
  else
    launch_zellij_session "$ZEL_SESSION_FULL" "$ZEL_CONFIG_KDL"
  fi
}

download_zellij() {
  local dry_run="${1:-false}"

  if [[ "$dry_run" == true ]]; then
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "download_dir=\$(mktemp -d)"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "curl -fsSL \"$ZEL_DOWNLOAD_URL\" -o \"\$download_dir/zellij\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$ZEL_INSTALL_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"\$download_dir/zellij\" \"$ZEL_BINARY_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "chmod +x \"$ZEL_BINARY_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -rf \"\$download_dir\""
    return
  fi

  local download_dir
  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mktemp -d"
  download_dir="$(mktemp -d)"
  local download_target="${download_dir}/zellij"

  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "curl -fsSL \"$ZEL_DOWNLOAD_URL\" -o \"$download_target\""
  if ! curl -fsSL "$ZEL_DOWNLOAD_URL" -o "$download_target"; then
    rm -rf "$download_dir"
    echo "Failed to download zellij from $ZEL_DOWNLOAD_URL" >&2
    exit 1
  fi

  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$ZEL_INSTALL_PATH\""
  mkdir -p "$ZEL_INSTALL_PATH"
  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$download_target\" \"$ZEL_BINARY_PATH\""
  cp "$download_target" "$ZEL_BINARY_PATH"
  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "chmod +x \"$ZEL_BINARY_PATH\""
  chmod +x "$ZEL_BINARY_PATH"
  printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -rf \"$download_dir\""
  rm -rf "$download_dir"
}

run_reset_command() {
  local delete_full="${1:-true}"
  local delete_thin="${2:-true}"

  print_header "zel.sh reset" "Deleting configured Zellij sessions [full / thin]"

  if [[ "$delete_full" == true ]]; then
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zellij delete-session $ZEL_SESSION_FULL --force"
    if zellij delete-session "$ZEL_SESSION_FULL" --force; then
      printf '\n%bDeleted session: %s%b\n\n' "$COLOR_YELLOW" "$ZEL_SESSION_FULL" "$COLOR_RESET"
    else
      printf '\n%bFailed to delete session: %s%b\n\n' "$COLOR_YELLOW" "$ZEL_SESSION_FULL" "$COLOR_RESET" >&2
    fi
  fi

  if [[ "$delete_thin" == true ]]; then
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zellij delete-session $ZEL_SESSION_THIN"
    if zellij delete-session "$ZEL_SESSION_THIN"; then
      printf '\n%bDeleted session: %s%b\n\n' "$COLOR_YELLOW" "$ZEL_SESSION_THIN" "$COLOR_RESET"
    else
      printf '\n%bFailed to delete session: %s%b\n\n' "$COLOR_YELLOW" "$ZEL_SESSION_THIN" "$COLOR_RESET" >&2
    fi
  fi
}

run_package_command() {
  local dry_run="${1:-false}"
  local version_increment="${2:-patch}"
  local new_version="${3:-}"

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"

  # Determine the version to use
  if [[ -n "$new_version" ]]; then
    # Use specified version
    package_version="$new_version"
  else
    # Increment current version
    package_version=$(increment_version "$XY_PACKAGE_VERSION" "$version_increment")
  fi

  zip_filename="${XY_PREFIX}${XY_PACKAGE_NAME}-${package_version}.zip"
  output_dir="${script_dir}/${XY_PACKAGE_OUT}"
  zip_path="${output_dir}${zip_filename}"

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh package" "Dry run: would create package ${zip_filename} in ${output_dir}"
    printf "%b\n\n" "${COLOR_YELLOW}Package steps to be run:${COLOR_RESET}"
    if [[ -n "$new_version" ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "update version to $package_version and date in script"
    else
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "increment $version_increment version: $XY_PACKAGE_VERSION -> $package_version and update date"
    fi
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    echo
    printf "%b\n" "${COLOR_YELLOW}Output file would be: $zip_path${COLOR_RESET}"
    printf "%b\n\n" "${COLOR_GRAY}Note: All .zip files in the zel directory will be excluded from the package.${COLOR_RESET}"
  else
    print_header "zel.sh package" "Creating package ${zip_filename} in ${output_dir}"

    # Update version in script
    if [[ -n "$new_version" ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "update version to $package_version and date in script"
    else
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "increment $version_increment version: $XY_PACKAGE_VERSION -> $package_version and update date"
    fi
    update_version_in_script "$package_version" "$script_path"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    mkdir -p "$output_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    cd "$script_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    if zip -r "$zip_path" . -x '*.zip'; then
      echo
      printf "%b\n" "${COLOR_GREEN}Package created successfully: $zip_path${COLOR_RESET}"
      printf "%b\n" "${COLOR_GREEN}Version updated to: $package_version${COLOR_RESET}"
      printf "%b\n\n" "${COLOR_GRAY}All .zip files in the zel directory were excluded from the package.${COLOR_RESET}"
    else
      echo
      printf "%b\n\n" "${COLOR_RED}Failed to create package.${COLOR_RESET}" >&2
      exit 1
    fi
  fi
}

if [[ "$1" == "package" ]]; then
  shift
  dry_run=false
  version_increment="patch"
  new_version=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        ;;
      --ver)
        if [[ -z "$2" ]]; then
          echo "Error: --ver requires a version number" >&2
          exit 1
        fi
        new_version="$2"
        shift
        ;;
      --maj|--major)
        version_increment="major"
        ;;
      --min|--minor)
        version_increment="minor"
        ;;
      --patch)
        version_increment="patch"
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  run_package_command "$dry_run" "$version_increment" "$new_version"
  exit 0
fi

if [[ "$1" == "download" ]]; then
  shift
  dry_run=false
  if [[ "$1" == "--dry-run" ]]; then
    dry_run=true
    shift
  fi

  if [[ -n "$1" ]]; then
    print_usage >&2
    exit 1
  fi

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh download" "Dry run: would download the latest Zellij binary into $ZEL_BINARY_PATH"
  else
    print_header "zel.sh download" "Downloading the latest Zellij binary into $ZEL_BINARY_PATH"
  fi

  download_zellij "$dry_run"
  exit 0
fi

if [[ "$1" == "update" ]]; then
  shift
  dry_run=false
  fix_path=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        ;;
      --fix-path)
        fix_path=true
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  config_dir="$script_dir/config"

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh update" "Dry run: would update .kdl config files in $ZEL_CONFIG_DIR_PATH"
    printf "%b\n\n" "${COLOR_YELLOW}Update steps to be run:${COLOR_RESET}"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p $ZEL_CONFIG_DIR_PATH"
    if [[ -d "$config_dir" ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$path\" \"$target_path\""
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    if [[ "$fix_path" == true ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "replace ${ZEL_CONFIG_PREFIX_DEFAULT} -> $ZEL_CONFIG_DIR_PATH in ${ZEL_CONFIG_DIR_PATH}${relative_path}"
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    echo
  else
    print_header "zel.sh update" "Updating .kdl config files in $ZEL_CONFIG_DIR_PATH"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p $ZEL_CONFIG_DIR_PATH"
    mkdir -p "$ZEL_CONFIG_DIR_PATH"
    files_updated=0
    if [[ -d "$config_dir" ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$path\" \"$target_path\""
        cp "$path" "$target_path"
        ((files_updated++))
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    if [[ "$fix_path" == true ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        if [[ -f "$target_path" ]]; then
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "replace ${ZEL_CONFIG_PREFIX_DEFAULT} -> $ZEL_CONFIG_DIR_PATH in $target_path"
          sed -i "s|$ZEL_CONFIG_PREFIX_DEFAULT|$ZEL_CONFIG_DIR_PATH|g" "$target_path"
        fi
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    echo

    if [[ "$files_updated" -eq 0 ]]; then
      printf "%b\n\n" "\033[37mNo .kdl files found to update.${COLOR_RESET}"
    else
      printf "%b\n\n" "\033[37mUpdated ${files_updated} .kdl files.${COLOR_RESET}"
    fi
    printf "%b\n\n" "${COLOR_YELLOW}Update completed successfully.${COLOR_RESET}"
  fi
  exit 0
fi

if [[ "$1" == "import" ]]; then
  shift
  dry_run=false
  if [[ "$1" == "--dry-run" ]]; then
    dry_run=true
    shift
  fi

  if [[ -n "$1" ]]; then
    print_usage >&2
    exit 1
  fi

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  config_dir="$script_dir/config"

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh import" "Dry run: would import .kdl config files from $ZEL_CONFIG_DIR_PATH, backing up existing files"
    printf "%b\n\n" "${COLOR_YELLOW}Import steps to be run:${COLOR_RESET}"

    # Check main config files
    for file in "zel-config.kdl" "zel-config-thin.kdl"; do
      source_path="${ZEL_CONFIG_DIR_PATH}${file}"
      target_path="${config_dir}/${file}"
      if [[ -f "$source_path" ]]; then
        if [[ -f "$target_path" ]] && ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
          timestamp=$(date '+%Y%m%d_%H%M%S')
          backup_name="${file%.*}-${timestamp}.kdl"
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$target_path\" \"${config_dir}/${backup_name}\""
        fi
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$source_path\" \"$target_path\""
      fi
    done

    # Check layout files
    layouts_source_dir="${ZEL_CONFIG_DIR_PATH}layouts"
    layouts_target_dir="${config_dir}/layouts"
    if [[ -d "$layouts_source_dir" ]]; then
      while IFS= read -r source_path; do
        filename=$(basename "$source_path")
        target_path="${layouts_target_dir}/${filename}"
        if [[ -f "$target_path" ]] && ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
          timestamp=$(date '+%Y%m%d_%H%M%S')
          backup_name="${filename%.*}-${timestamp}.kdl"
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$target_path\" \"${layouts_target_dir}/${backup_name}\""
        fi
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$source_path\" \"$target_path\""
      done < <(find "$layouts_source_dir" -type f -name "*.kdl" -print | sort)
    fi
    echo
  else
    print_header "zel.sh import" "Importing .kdl config files from $ZEL_CONFIG_DIR_PATH, backing up existing files"
    files_imported=0
    files_backed_up=0

    # Import main config files
    for file in "zel-config.kdl" "zel-config-thin.kdl"; do
      source_path="${ZEL_CONFIG_DIR_PATH}${file}"
      target_path="${config_dir}/${file}"
      if [[ -f "$source_path" ]]; then
        if [[ -f "$target_path" ]] && ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
          timestamp=$(date '+%Y%m%d_%H%M%S')
          backup_name="${file%.*}-${timestamp}.kdl"
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$target_path\" \"${config_dir}/${backup_name}\""
          cp "$target_path" "${config_dir}/${backup_name}"
          ((files_backed_up++))
        fi
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$source_path\" \"$target_path\""
        cp "$source_path" "$target_path"
        ((files_imported++))
      fi
    done

    # Import layout files
    layouts_source_dir="${ZEL_CONFIG_DIR_PATH}layouts"
    layouts_target_dir="${config_dir}/layouts"
    if [[ -d "$layouts_source_dir" ]]; then
      mkdir -p "$layouts_target_dir"
      while IFS= read -r source_path; do
        filename=$(basename "$source_path")
        target_path="${layouts_target_dir}/${filename}"
        if [[ -f "$target_path" ]] && ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
          timestamp=$(date '+%Y%m%d_%H%M%S')
          backup_name="${filename%.*}-${timestamp}.kdl"
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$target_path\" \"${layouts_target_dir}/${backup_name}\""
          cp "$target_path" "${layouts_target_dir}/${backup_name}"
          ((files_backed_up++))
        fi
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$source_path\" \"$target_path\""
        cp "$source_path" "$target_path"
        ((files_imported++))
      done < <(find "$layouts_source_dir" -type f -name "*.kdl" -print | sort)
    fi
    echo

    if [[ "$files_imported" -eq 0 ]]; then
      printf "%b\n\n" "\033[37mNo .kdl files found to import.${COLOR_RESET}"
    else
      printf "%b\n" "\033[37mImported ${files_imported} .kdl files.${COLOR_RESET}"
      if [[ "$files_backed_up" -gt 0 ]]; then
        printf "%b\n" "\033[37mBacked up ${files_backed_up} existing files.${COLOR_RESET}"
      fi
      printf "\n"
    fi
    printf "%b\n\n" "${COLOR_YELLOW}Import completed successfully.${COLOR_RESET}"
  fi
  exit 0
fi

if [[ "$1" == "compare" ]]; then
  shift
  show_diff=false
  list_all=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --show-diff)
        show_diff=true
        ;;
      --list)
        list_all=true
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  config_dir="$script_dir/config"

  print_header "zel.sh compare" "Comparing .kdl config files between installed location and zel directory"

  # Calculate separator width to match header
  command_label="zel.sh compare"
  description="Comparing .kdl config files between installed location and zel directory"
  separator_width=${#description}
  cmd_width=${#command_label}
  if (( cmd_width > separator_width )); then
    separator_width=$cmd_width
  fi
  if (( separator_width == 0 )); then
    separator_width=20
  fi

  differences_found=0
  files_checked=0

  # Compare main config files
  for file in "zel-config.kdl" "zel-config-thin.kdl"; do
    source_path="${ZEL_CONFIG_DIR_PATH}${file}"
    target_path="${config_dir}/${file}"

    if [[ -f "$source_path" && -f "$target_path" ]]; then
      ((files_checked++))
      if ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
        ((differences_found++))
        printf "%b%s:%b\n" "$COLOR_HEADER" "$file" "$COLOR_RESET"

        # Get file sizes and hashes
        source_size=$(stat -c%s "$source_path" 2>/dev/null || echo "unknown")
        target_size=$(stat -c%s "$target_path" 2>/dev/null || echo "unknown")
        source_hash=$(sha256sum "$source_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        target_hash=$(sha256sum "$target_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

        printf "  🌐 %bRepo:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
        printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$target_size" "$COLOR_RESET" "$COLOR_CYAN" "${target_hash:0:16}..." "$COLOR_RESET"
        printf "  💻 %bInstalled:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
        printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$source_size" "$COLOR_RESET" "$COLOR_CYAN" "${source_hash:0:16}..." "$COLOR_RESET"

        if [[ "$show_diff" == true ]]; then
          echo
          # Show the actual differences
          printf "%bDifferences:%b\n" "$COLOR_WHITE" "$COLOR_RESET"
          diff -u "$target_path" "$source_path" | tail -n +3 | head -20
          echo
          if [[ $(diff -u "$target_path" "$source_path" | wc -l) -gt 23 ]]; then
            printf "%b... (showing first 20 lines of diff, use 'diff %s %s' to see all)%b\n\n" "$COLOR_GRAY" "$target_path" "$source_path" "$COLOR_RESET"
          fi
        else
          printf "  %bUse --show-diff to see file differences%b\n\n" "$COLOR_GRAY" "$COLOR_RESET"
        fi
      elif [[ "$list_all" == true ]]; then
        # Files are identical, but show them if --list is used
        printf "%b%s:%b\n" "$COLOR_HEADER" "$file" "$COLOR_RESET"

        # Get file sizes and hashes
        source_size=$(stat -c%s "$source_path" 2>/dev/null || echo "unknown")
        target_size=$(stat -c%s "$target_path" 2>/dev/null || echo "unknown")
        source_hash=$(sha256sum "$source_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
        target_hash=$(sha256sum "$target_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

        printf "  🌐 %bRepo:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
        printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$target_size" "$COLOR_RESET" "$COLOR_CYAN" "${target_hash:0:16}..." "$COLOR_RESET"
        printf "  💻 %bInstalled:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
        printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$source_size" "$COLOR_RESET" "$COLOR_CYAN" "${source_hash:0:16}..." "$COLOR_RESET"
        printf "  %bIdentical files%b\n\n" "$COLOR_GREEN" "$COLOR_RESET"
      fi
    elif [[ -f "$source_path" && ! -f "$target_path" ]]; then
      ((differences_found++))
      printf "%b%s:%b\n" "$COLOR_HEADER" "$file" "$COLOR_RESET"
      printf "  %b➖%b %bMissing in repo:%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
      printf "  %b➕%b %bExists in installed:%b %s\n\n" "$COLOR_GREEN" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
    elif [[ ! -f "$source_path" && -f "$target_path" ]]; then
      ((differences_found++))
      printf "%b%s:%b\n" "$COLOR_HEADER" "$file" "$COLOR_RESET"
      printf "  %b➖%b %bMissing in installed:%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
      printf "  %b➕%b %bExists in repo:%b %s\n\n" "$COLOR_GREEN" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
    fi
  done

  # Compare layout files
  layouts_source_dir="${ZEL_CONFIG_DIR_PATH}layouts"
  layouts_target_dir="${config_dir}/layouts"

  if [[ -d "$layouts_source_dir" ]]; then
    while IFS= read -r source_path; do
      filename=$(basename "$source_path")
      target_path="${layouts_target_dir}/${filename}"

      if [[ -f "$target_path" ]]; then
        ((files_checked++))
        if ! diff -q "$source_path" "$target_path" >/dev/null 2>&1; then
          ((differences_found++))
          printf "%b%s:%b\n" "$COLOR_HEADER" "layouts/$filename" "$COLOR_RESET"

          # Get file sizes and hashes
          source_size=$(stat -c%s "$source_path" 2>/dev/null || echo "unknown")
          target_size=$(stat -c%s "$target_path" 2>/dev/null || echo "unknown")
          source_hash=$(sha256sum "$source_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
          target_hash=$(sha256sum "$target_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

          printf "  🌐 %bRepo:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
          printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$target_size" "$COLOR_RESET" "$COLOR_CYAN" "${target_hash:0:16}..." "$COLOR_RESET"
          printf "  💻 %bInstalled:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
          printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$source_size" "$COLOR_RESET" "$COLOR_CYAN" "${source_hash:0:16}..." "$COLOR_RESET"

          if [[ "$show_diff" == true ]]; then
            echo
            # Show the actual differences
            printf "%bDifferences:%b\n" "$COLOR_WHITE" "$COLOR_RESET"
            diff -u "$target_path" "$source_path" | tail -n +3 | head -20
            echo
            if [[ $(diff -u "$target_path" "$source_path" | wc -l) -gt 23 ]]; then
              printf "%b... (showing first 20 lines of diff, use 'diff %s %s' to see all)%b\n\n" "$COLOR_GRAY" "$target_path" "$source_path" "$COLOR_RESET"
            fi
          else
            printf "  %bUse --show-diff to see file differences%b\n\n" "$COLOR_GRAY" "$COLOR_RESET"
          fi
        elif [[ "$list_all" == true ]]; then
          # Files are identical, but show them if --list is used
          printf "%b%s:%b\n" "$COLOR_HEADER" "layouts/$filename" "$COLOR_RESET"

          # Get file sizes and hashes
          source_size=$(stat -c%s "$source_path" 2>/dev/null || echo "unknown")
          target_size=$(stat -c%s "$target_path" 2>/dev/null || echo "unknown")
          source_hash=$(sha256sum "$source_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
          target_hash=$(sha256sum "$target_path" 2>/dev/null | cut -d' ' -f1 || echo "unknown")

          printf "  🌐 %bRepo:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
          printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$target_size" "$COLOR_RESET" "$COLOR_CYAN" "${target_hash:0:16}..." "$COLOR_RESET"
          printf "  💻 %bInstalled:%b %s\n" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
          printf "            [ %b%s bytes%b | %b%s%b ]\n" "$COLOR_MAGENTA" "$source_size" "$COLOR_RESET" "$COLOR_CYAN" "${source_hash:0:16}..." "$COLOR_RESET"
          printf "  %bIdentical files%b\n\n" "$COLOR_GREEN" "$COLOR_RESET"
        fi
      else
        ((differences_found++))
        printf "%b%s:%b\n" "$COLOR_HEADER" "layouts/$filename" "$COLOR_RESET"
        printf "  %b➖%b %bMissing in repo:%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
        printf "  %b➕%b %bExists in installed:%b %s\n\n" "$COLOR_GREEN" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
      fi
    done < <(find "$layouts_source_dir" -type f -name "*.kdl" -print | sort)
  fi

  # Check for files that exist in zel repo but not in installed location
  if [[ -d "$layouts_target_dir" ]]; then
    while IFS= read -r target_path; do
      filename=$(basename "$target_path")
      source_path="${layouts_source_dir}/${filename}"

      if [[ ! -f "$source_path" ]]; then
        ((differences_found++))
        printf "%b%s:%b\n" "$COLOR_HEADER" "layouts/$filename" "$COLOR_RESET"
        printf "  %b➖%b %bMissing in installed:%b %s\n" "$COLOR_RED" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$source_path"
        printf "  %b➕%b %bExists in repo:%b %s\n\n" "$COLOR_GREEN" "$COLOR_RESET" "$COLOR_WHITE" "$COLOR_RESET" "$target_path"
      fi
    done < <(find "$layouts_target_dir" -type f -name "*.kdl" -print | sort)
  fi

  # Summary
  if [[ "$differences_found" -eq 0 ]]; then
    printf " %b\n\n" "${COLOR_GREEN}All .kdl files are identical between installed location and zel directory.${COLOR_RESET}"
    printf " %b\n\n" "\033[37mChecked ${files_checked} files.${COLOR_RESET}"
  else
    bottom_separator=$(create_separator "$separator_width")
    printf '%s\n\n' "$bottom_separator"
    printf " %b\n\n" "${COLOR_YELLOW}Found ${differences_found} differences between installed and zel directory files.${COLOR_RESET}"
    printf " %b\n\n" "\033[37mUse 'zel.sh import' to sync changes from installed location.${COLOR_RESET}"
  fi

  exit 0
fi

if [[ "$1" == "version" ]]; then
  shift
  only_version=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --only)
        only_version=true
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  if [[ "$only_version" == true ]]; then
    echo "$XY_PACKAGE_VERSION"
  else
    # Custom header with banner width separator
    separator_width=70
    separator=$(create_separator "$separator_width")

    echo
    printf " %b %b\n" "${COLOR_LABEL}zel.sh${COLOR_RESET}" "\033[37mversion${COLOR_RESET}"
    printf "\n"
    printf " %bPackage information%b\n" "$COLOR_GRAY" "$COLOR_RESET"
    printf "\n"
    printf "%s\n\n" "$separator"

    printf " %bName:%b %b%s%b\n\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_NAME" "$COLOR_RESET"
    printf " %bDescription:%b %b%s%b\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_DESCRIPTION" "$COLOR_RESET"
    printf " %bVersion:%b %b%s%b\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_VERSION" "$COLOR_RESET"
    printf " %bDate:%b %b%s%b\n\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_DATE" "$COLOR_RESET"

    printf "%s\n\n" "$separator"

    # Print ASCII banner in gray
    printf "\n%b" "$COLOR_GRAY"
    cat << 'EOF'
                                                      888
                                                      888
                                                      888
888  888 888  888          88888b.   8888b.   .d8888b 888  888
`Y8bd8P' 888  888          888 "88b     "88b d88P"    888 .88P
  X88K   888  888          888  888 .d888888 888      888888K
.d8""8b. Y88b 888          888 d88P 888  888 Y88b.    888 "88b
888  888  "Y88888 88888888 88888P"  "Y888888  "Y8888P 888  888
              888          888
         Y8b d88P          888
          "Y88P"           888
EOF
    printf "%b\n\n\n" "$COLOR_RESET"
  fi
  exit 0
fi

if [[ "$1" == "help" ]]; then
  print_usage
  exit 0
fi

if [[ "$1" == "reset" ]]; then
  shift
  delete_full=true
  delete_thin=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --full-only)
        delete_thin=false
        ;;
      --thin-only)
        delete_full=false
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  run_reset_command "$delete_full" "$delete_thin"
  exit 0
fi

if [[ "$1" == "respond" || "$1" == "adapt" || "$1" == "fit" ]]; then
  shift
  dry_run=false
  reset_before_launch=false
  manual_cols=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        ;;
      --reset)
        reset_before_launch=true
        ;;
      [0-9]*)
        if [[ -n "$manual_cols" ]]; then
          print_usage >&2
          exit 1
        fi
        if [[ "$1" =~ ^[0-9]+$ ]]; then
          manual_cols="$1"
        else
          print_usage >&2
          exit 1
        fi
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  if [[ "$dry_run" == true && "$reset_before_launch" == true ]]; then
    echo "--reset cannot be combined with --dry-run for respond" >&2
    exit 1
  fi

  if [[ "$reset_before_launch" == true ]]; then
    run_reset_command true true
  fi

  run_respond "$dry_run" "$manual_cols"
  exit 0
fi

if [[ "$1" == "install" ]]; then
  shift
  dry_run=false
  fix_path=false
  skip_download=false
  use_zel_default=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        dry_run=true
        ;;
      --fix-path)
        fix_path=true
        ;;
      --skip-download)
        skip_download=true
        ;;
      --use-zel-default)
        use_zel_default=true
        ;;
      *)
        print_usage >&2
        exit 1
        ;;
    esac
    shift
  done

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  config_dir="$script_dir/config"

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh install" "Dry run: would download Zellij, seed $ZEL_CONFIG_DIR_PATH, and link zel presets"
    printf "%b\n\n" "${COLOR_YELLOW}Install steps to be run:${COLOR_RESET}"
    if [[ "$skip_download" == false ]]; then
      download_zellij true
    else
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$ZEL_INSTALL_PATH\""
    fi
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p $ZEL_CONFIG_DIR_PATH"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp -r $config_dir/. $ZEL_CONFIG_DIR_PATH"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "ln -sf \"$script_path\" \"$ZEL_SCRIPT_SYMLINK\""
    if [[ "$use_zel_default" == true ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "ln -sf \"${ZEL_CONFIG_DIR_PATH}zel-config.kdl\" \"${ZEL_CONFIG_DIR_PATH}config.kdl\""
    fi
    if [[ "$fix_path" == true ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "replace ${ZEL_CONFIG_PREFIX_DEFAULT} -> $ZEL_CONFIG_DIR_PATH in ${ZEL_CONFIG_DIR_PATH}${relative_path}"
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    echo
    printf "%b\n\n" "${COLOR_YELLOW}File structure to be created:${COLOR_RESET}"
    print_tree_structure "$config_dir" "$ZEL_CONFIG_DIR_PATH"
    echo
    printf "%b\n\n" "${COLOR_YELLOW}Executables to be created:${COLOR_RESET}"
    echo "  $ZEL_BINARY_PATH"
    echo
  else
    print_header "zel.sh install" "Downloading Zellij, seeding $ZEL_CONFIG_DIR_PATH, and linking zel presets"
    if [[ "$skip_download" == false ]]; then
      download_zellij false
    else
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$ZEL_INSTALL_PATH\""
      mkdir -p "$ZEL_INSTALL_PATH"
    fi
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p $ZEL_CONFIG_DIR_PATH"
    mkdir -p "$ZEL_CONFIG_DIR_PATH"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp -r $config_dir/. $ZEL_CONFIG_DIR_PATH"
    cp -r "$config_dir/." "$ZEL_CONFIG_DIR_PATH"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "ln -sf \"$script_path\" \"$ZEL_SCRIPT_SYMLINK\""
    ln -sf "$script_path" "$ZEL_SCRIPT_SYMLINK"
    if [[ "$use_zel_default" == true ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "ln -sf \"${ZEL_CONFIG_DIR_PATH}zel-config.kdl\" \"${ZEL_CONFIG_DIR_PATH}config.kdl\""
      ln -sf "${ZEL_CONFIG_DIR_PATH}zel-config.kdl" "${ZEL_CONFIG_DIR_PATH}config.kdl"
    fi
    if [[ "$fix_path" == true ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        if [[ -f "$target_path" ]]; then
          printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "replace ${ZEL_CONFIG_PREFIX_DEFAULT} -> $ZEL_CONFIG_DIR_PATH in $target_path"
          sed -i "s|$ZEL_CONFIG_PREFIX_DEFAULT|$ZEL_CONFIG_DIR_PATH|g" "$target_path"
        fi
      done < <(find "$config_dir" -type f -name '*.kdl' -print | sort)
    fi
    echo
    printf "%b\n\n" "\033[92mInstall completed successfully.${COLOR_RESET}"
  fi
  exit 0
fi

if [[ "$1" == "uninstall" ]]; then
  shift
  dry_run=false
  keep_zellij=false
  if [[ "$1" == "--dry-run" ]]; then
    dry_run=true
    shift
  fi

  if [[ "$1" == "--keep-zellij" ]]; then
    keep_zellij=true
    shift
  fi

  if [[ -n "$1" ]]; then
    print_usage >&2
    exit 1
  fi

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  config_dir="$script_dir/config"

  if [[ "$dry_run" == true ]]; then
    print_header "zel.sh uninstall" "Dry run: would remove Zellij configs, symlink, and installed binary (.config/zellij and .config/zellij/layouts preserved)"
    printf "%b\n\n" "${COLOR_YELLOW}Uninstall steps to be run:${COLOR_RESET}"
    if [[ -d "$config_dir" ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $target_path"
      done < <(find "$config_dir" -type f \( -name "*.kdl" -o -name "*.wasm" \) -print | sort)
    fi
    if [[ "$keep_zellij" == false ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $ZEL_BINARY_PATH"
    fi
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $ZEL_SCRIPT_SYMLINK"
    echo
  else
    print_header "zel.sh uninstall" "Removing Zellij configs, symlink, and installed binary (.config/zellij and .config/zellij/layouts preserved)"
    files_deleted=0
    if [[ -d "$config_dir" ]]; then
      while IFS= read -r path; do
        relative_path="${path#"$config_dir/"}"
        target_path="${ZEL_CONFIG_DIR_PATH}${relative_path}"
        printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $target_path"
        if [[ -f "$target_path" ]]; then
          ((files_deleted++))
        fi
        rm -f "$target_path"
      done < <(find "$config_dir" -type f \( -name "*.kdl" -o -name "*.wasm" \) -print | sort)
    fi
    if [[ "$keep_zellij" == false ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $ZEL_BINARY_PATH"
      if [[ -f "$ZEL_BINARY_PATH" ]]; then
        ((files_deleted++))
      fi
      rm -f "$ZEL_BINARY_PATH"
    fi
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f $ZEL_SCRIPT_SYMLINK"
    if [[ -f "$ZEL_SCRIPT_SYMLINK" ]]; then
      ((files_deleted++))
    fi
    rm -f "$ZEL_SCRIPT_SYMLINK"
    echo

    if [[ "$files_deleted" -eq 0 ]]; then
      printf "%b\n\n" "\033[37mNo files deleted.${COLOR_RESET}"
    else
      printf "%b\n\n" "\033[37mDeleted ${files_deleted} files.${COLOR_RESET}"
    fi
    printf "%b\n\n" "${COLOR_YELLOW}Uninstall completed successfully.${COLOR_RESET}"
  fi
  exit 0
fi

# Default behavior: if no arguments, run respond command
if [[ $# -eq 0 ]]; then
  run_respond false ""
  exit 0
fi

reset_before_launch=false
if [[ "$1" == "--reset" ]]; then
  reset_before_launch=true
  shift
fi

if [[ "$1" == "thin" ]]; then
  ZEL_CONFIG_PATH="$ZEL_CONFIG_THIN_PATH"
  ZEL_SESSION="$ZEL_SESSION_THIN"
elif [[ "$1" == "full" ]]; then
  ZEL_CONFIG_PATH="$ZEL_CONFIG_KDL"
  ZEL_SESSION="$ZEL_SESSION_FULL"
elif [[ -n "$1" ]]; then
  print_usage >&2
  exit 1
fi

if [[ "$reset_before_launch" == true ]]; then
  run_reset_command true true
fi

launch_zellij_session "$ZEL_SESSION" "$ZEL_CONFIG_PATH"

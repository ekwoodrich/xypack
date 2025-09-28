#!/bin/bash
# Demo installer for the xypack standard format

XY_PACKAGE_NAME="xyp"
XY_PACKAGE_DESCRIPTION="Demo installer for the xypack standard format"
XY_PACKAGE_VERSION="1.0.0"
XY_PREFIX="xy_"
XY_PACKAGE_OUT="../../zip/"

XY_THIN_COLS=100

XYP_DOWNLOAD_URL="https://github.com/ekwoodrich/xypack/releases/download/v1.0.0/xy_pack.sh"
XYP_INSTALL_PATH="/usr/local/bin"
XYP_BINARY_NAME="xy_pack"
XYP_BINARY_PATH="${XYP_INSTALL_PATH}/${XYP_BINARY_NAME}"

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
  printf '%bUsage: ./xyp.sh [command] [options]%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  printf '  %b %b [--dry-run]\n' \
    "${COLOR_LABEL}xyp.sh${COLOR_RESET}" "\033[92minstall${COLOR_RESET}"
  printf '      %bDownload xy_pack.sh and install it to /usr/local/bin as xy_pack.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  printf '  %b %b [--dry-run]\n' \
    "${COLOR_LABEL}xyp.sh${COLOR_RESET}" "${COLOR_RED}uninstall${COLOR_RESET}"
  printf '      %bRemove the xy_pack binary from /usr/local/bin.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  printf '  %b %b [--dry-run]\n' \
    "${COLOR_LABEL}xyp.sh${COLOR_RESET}" "${COLOR_LIGHT_GRAY}package${COLOR_RESET}"
  printf '      %bCreate a versioned zip package of the xyp directory, excluding existing .zip files.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  printf '  %b %b [--only]\n' \
    "${COLOR_LABEL}xyp.sh${COLOR_RESET}" "\033[37mversion${COLOR_RESET}"
  printf '      %bShow package name, description, and version. Use --only to show just the version.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  printf '  %b %b\n' \
    "${COLOR_LABEL}xyp.sh${COLOR_RESET}" "help"
  printf '      %bShow this help message.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
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
    elif [[ "$remainder" == uninstall ]]; then
      color="$COLOR_RED"
    elif [[ "$remainder" == package ]]; then
      color="$COLOR_LIGHT_GRAY"
    elif [[ "$remainder" == version ]]; then
      color="\033[37m"
    fi
    printf " %b %b\n" "${COLOR_LABEL}${base_label}${COLOR_RESET}" "${color}${remainder}${COLOR_RESET}"
  else
    printf " %b\n" "${COLOR_LABEL}${base_label}${COLOR_RESET}"
  fi
  printf "\n"
  if [[ -n "$description" ]]; then
    printf " %b%s%b\n" "$COLOR_GRAY" "$description" "$COLOR_RESET"
  fi
  printf "\n"
  printf "%s\n\n" "$separator"
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

run_install_command() {
  local dry_run="${1:-false}"

  if [[ "$dry_run" == true ]]; then
    print_header "xyp install" "Dry run: would download and install xy_pack to ${XYP_BINARY_PATH}"
    printf "%b\n\n" "${COLOR_YELLOW}Install steps to be run:${COLOR_RESET}"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "download_dir=\$(mktemp -d)"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "curl -fsSL \"$XYP_DOWNLOAD_URL\" -o \"\$download_dir/$XYP_BINARY_NAME\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$XYP_INSTALL_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"\$download_dir/$XYP_BINARY_NAME\" \"$XYP_BINARY_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "chmod +x \"$XYP_BINARY_PATH\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -rf \"\$download_dir\""
    echo
    printf "%b\n" "${COLOR_YELLOW}Binary would be installed to: $XYP_BINARY_PATH${COLOR_RESET}"
    echo
  else
    print_header "xyp install" "Downloading and installing xy_pack to ${XYP_BINARY_PATH}"

    local download_dir
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mktemp -d"
    download_dir="$(mktemp -d)"
    local download_target="${download_dir}/${XYP_BINARY_NAME}"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "curl -fsSL \"$XYP_DOWNLOAD_URL\" -o \"$download_target\""
    if ! curl -fsSL "$XYP_DOWNLOAD_URL" -o "$download_target"; then
      rm -rf "$download_dir"
      echo
      printf "%b\n\n" "${COLOR_RED}Failed to download xy_pack from $XYP_DOWNLOAD_URL${COLOR_RESET}" >&2
      exit 1
    fi

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$XYP_INSTALL_PATH\""
    mkdir -p "$XYP_INSTALL_PATH"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cp \"$download_target\" \"$XYP_BINARY_PATH\""
    cp "$download_target" "$XYP_BINARY_PATH"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "chmod +x \"$XYP_BINARY_PATH\""
    chmod +x "$XYP_BINARY_PATH"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -rf \"$download_dir\""
    rm -rf "$download_dir"

    echo
    printf "%b\n" "${COLOR_GREEN}Install completed successfully: $XYP_BINARY_PATH${COLOR_RESET}"
    printf "%b\n\n" "${COLOR_LIGHT_GRAY}You can now run 'xy_pack' from anywhere.${COLOR_RESET}"
    echo
  fi
}

run_uninstall_command() {
  local dry_run="${1:-false}"

  if [[ "$dry_run" == true ]]; then
    print_header "xyp uninstall" "Dry run: would remove xy_pack from ${XYP_BINARY_PATH}"
    printf "%b\n\n" "${COLOR_YELLOW}Uninstall steps to be run:${COLOR_RESET}"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f \"$XYP_BINARY_PATH\""
    echo
    if [[ -f "$XYP_BINARY_PATH" ]]; then
      printf "%b\n" "${COLOR_YELLOW}Binary exists and would be removed: $XYP_BINARY_PATH${COLOR_RESET}"
      echo
    else
      printf "%b\n" "${COLOR_YELLOW}Binary does not exist: $XYP_BINARY_PATH${COLOR_RESET}"
      echo
    fi
  else
    print_header "xyp uninstall" "Removing xy_pack from ${XYP_BINARY_PATH}"

    if [[ -f "$XYP_BINARY_PATH" ]]; then
      printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "rm -f \"$XYP_BINARY_PATH\""
      rm -f "$XYP_BINARY_PATH"
      echo
      printf "%b\n\n" "${COLOR_GREEN}Uninstall completed successfully${COLOR_RESET}"
    echo
    else
      echo
      printf "%b\n\n" "${COLOR_YELLOW}xy_pack binary not found at $XYP_BINARY_PATH${COLOR_RESET}"
    echo
    fi
  fi
}

run_package_command() {
  local dry_run="${1:-false}"

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  datetime=$(date '+%Y%m%d_%H%M%S')
  zip_filename="${XY_PREFIX}${XY_PACKAGE_NAME}-${datetime}.zip"
  output_dir="${script_dir}/${XY_PACKAGE_OUT}"
  zip_path="${output_dir}${zip_filename}"

  if [[ "$dry_run" == true ]]; then
    print_header "xyp package" "Dry run: would create package ${zip_filename} in ${output_dir}"
    printf "%b\n\n" "${COLOR_YELLOW}Package steps to be run:${COLOR_RESET}"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    echo
    printf "%b\n" "${COLOR_YELLOW}Output file would be: $zip_path${COLOR_RESET}"
    echo
  else
    print_header "xyp package" "Creating package ${zip_filename} in ${output_dir}"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    mkdir -p "$output_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    cd "$script_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    if zip -r "$zip_path" . -x '*.zip'; then
      echo
      printf "%b\n" "${COLOR_GREEN}Package created successfully: $zip_path${COLOR_RESET}"
    echo
    else
      echo
      printf "%b\n\n" "${COLOR_RED}Failed to create package.${COLOR_RESET}" >&2
      exit 1
    fi
  fi
}

if [[ "$1" == "install" ]]; then
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

  run_install_command "$dry_run"
  exit 0
fi

if [[ "$1" == "uninstall" ]]; then
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

  run_uninstall_command "$dry_run"
  exit 0
fi

if [[ "$1" == "package" ]]; then
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

  run_package_command "$dry_run"
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
    print_header "xyp version" "Package information"
    printf " %bName:%b %b%s%b\n\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_NAME" "$COLOR_RESET"
    printf " %bDescription:%b %b%s%b\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_DESCRIPTION" "$COLOR_RESET"
    printf " %bVersion:%b %b%s%b\n\n" "$COLOR_WHITE" "$COLOR_RESET" "$COLOR_GRAY" "$XY_PACKAGE_VERSION" "$COLOR_RESET"
  fi
  exit 0
fi

if [[ "$1" == "help" ]]; then
  print_usage
  exit 0
fi

print_usage >&2
exit 1
# XYPACK Package Template

A **xypack** is a standardized convention for internal application installers and management scripts. This template defines the UI/UX patterns, command structure, and conventions that all xypack-compliant scripts should follow.

## Core Principles

- **Consistent User Experience**: All xypack scripts share identical styling, colors, and command patterns
- **Standardized Commands**: Every xypack must implement `help`, `package`, and typically `install`/`uninstall`
- **Predictable Variables**: Standard variable naming and placement conventions
- **Clear Output**: Styled headers, separators, and command feedback with consistent coloring

## Required Standard Variables

All xypack scripts must define these variables at the top of the file, in this exact order:

```bash
#!/bin/bash
# [Brief description of the script's purpose]

XY_PACKAGE_NAME="[package-name]"
XY_PACKAGE_DESCRIPTION="[Brief description matching header comment]"
XY_PACKAGE_VERSION="[semantic-version]"
XY_PREFIX="xy_"
XY_PACKAGE_OUT="../../zip/"

XY_THIN_COLS=100

# Application-specific variables follow below...
```

### Standard Variable Definitions

- **`XY_PACKAGE_NAME`**: The package identifier used in zip filenames (e.g., "zel", "myapp")
- **`XY_PACKAGE_DESCRIPTION`**: Single-line description of the script's purpose
- **`XY_PACKAGE_VERSION`**: Semantic version string (e.g., "1.0.0", "2.1.3")
- **`XY_PREFIX`**: Prefix for generated zip files (default: "xy_")
- **`XY_PACKAGE_OUT`**: Output directory for package files (default: "../../zip/")
- **`XY_THIN_COLS`**: Column threshold for responsive layouts (default: 100)

## Required Color Palette

All xypack scripts must use this exact color scheme:

```bash
COLOR_GREEN="\033[32m"
COLOR_YELLOW="\033[33m"
COLOR_RED="\033[31m"
COLOR_LIGHT_BLUE="\033[94m"
COLOR_WHITE="\033[97m"
COLOR_LIGHT_GRAY="\033[37m"
COLOR_GRAY="\033[90m"
COLOR_MAGENTA="\033[95m"
COLOR_CYAN="\033[96m"
COLOR_LABEL="\033[30;47m"        # Black text on white background
COLOR_HEADER="\033[30;47m"       # Black text on white background
COLOR_RESET="\033[0m"
```

## Required Commands

### 1. Help Command (`help`)

Every xypack must implement a `help` command with this exact styling:

```bash
print_usage() {
  echo
  printf '%bUsage: ./[script-name] [command] [options]%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"

  # Command entries use this format:
  printf '  %b %b [options]\n' \
    "${COLOR_LABEL}[script-name]${COLOR_RESET}" "${COLOR_GREEN}command${COLOR_RESET}"
  printf '      %bDescription of what the command does.%b\n\n' "$COLOR_GRAY" "$COLOR_RESET"
}
```

**Styling Rules:**
- Script name appears in `COLOR_LABEL` (white background, black text)
- Primary commands use `COLOR_GREEN` or `\033[92m` (bright green)
- Destructive commands use `COLOR_RED`
- Utility commands use `COLOR_YELLOW`
- Update/maintenance commands use `\033[37m` (light gray)
- Special commands use `COLOR_CYAN`
- Description text uses `COLOR_GRAY`

### 2. Package Command (`package`)

All xypack scripts must implement a standardized `package` command:

```bash
run_package_command() {
  local dry_run="${1:-false}"

  script_path="$(realpath "$0")"
  script_dir="$(dirname "$script_path")"
  datetime=$(date '+%Y%m%d_%H%M%S')
  zip_filename="${XY_PREFIX}${XY_PACKAGE_NAME}-${datetime}.zip"
  output_dir="${script_dir}/${XY_PACKAGE_OUT}"
  zip_path="${output_dir}${zip_filename}"

  if [[ "$dry_run" == true ]]; then
    print_header "[script] package" "Dry run: would create package ${zip_filename} in ${output_dir}"
    printf "%b\n\n" "${COLOR_YELLOW}Package steps to be run:${COLOR_RESET}"
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    echo
    printf "%b\n" "${COLOR_YELLOW}Output file would be: $zip_path${COLOR_RESET}"
  else
    print_header "[script] package" "Creating package ${zip_filename} in ${output_dir}"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "mkdir -p \"$output_dir\""
    mkdir -p "$output_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "cd \"$script_dir\""
    cd "$script_dir"

    printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "zip -r \"$zip_path\" . -x '*.zip'"
    if zip -r "$zip_path" . -x '*.zip'; then
      echo
      printf "%b\n" "${COLOR_GREEN}Package created successfully: $zip_path${COLOR_RESET}"
    else
      echo
      printf "%b\n\n" "${COLOR_RED}Failed to create package.${COLOR_RESET}" >&2
      exit 1
    fi
  fi
}
```

### 3. Install Command (`install`)

Most xypack scripts should implement an `install` command following this pattern:

```bash
# Must support --dry-run flag
# Should include progress feedback with print_header()
# Use consistent command output formatting with " > " prefix
print_header "[script] install" "[Description of installation process]"
```

### 4. Uninstall Command (`uninstall`)

Most xypack scripts should implement an `uninstall` command:

```bash
# Must support --dry-run flag
# Should use COLOR_RED for destructive operations in help text
# Include safety prompts for destructive operations
print_header "[script] uninstall" "[Description of removal process]"
```

## Required UI Functions

### Header Function

```bash
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
    # Color logic based on command type
    if [[ "$remainder" == install ]]; then
      color="\033[92m"
    elif [[ "$remainder" == uninstall ]]; then
      color="$COLOR_RED"
    elif [[ "$remainder" == package ]]; then
      color="$COLOR_CYAN"
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
```

### Separator Function

```bash
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
```

## Command Output Formatting

### Command Execution Display

All command execution should use this format:

```bash
printf " %b>%b %s\n" "$COLOR_GRAY" "$COLOR_RESET" "[command-to-run]"
```

This creates output like:
```
 > mkdir -p "/target/directory"
 > curl -fsSL "https://example.com" -o "file"
```

### Status Messages

```bash
# Success messages
printf "%b\n" "${COLOR_GREEN}Operation completed successfully${COLOR_RESET}"

# Warning messages
printf "%b\n" "${COLOR_YELLOW}Warning: Something to note${COLOR_RESET}"

# Error messages
printf "%b\n" "${COLOR_RED}Error: Operation failed${COLOR_RESET}" >&2
```

## Command Line Argument Handling

### Standard --dry-run Support

All commands that modify the filesystem must support `--dry-run`:

```bash
if [[ "$1" == "command-name" ]]; then
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

  run_command_function "$dry_run"
  exit 0
fi
```

### Help Command Handling

```bash
if [[ "$1" == "help" ]]; then
  print_usage
  exit 0
fi
```

## File Structure Conventions

### Directory Layout

```
/[package-name]/
├── [main-script].sh          # Primary executable script
├── README.md                 # Documentation following standard format
├── [config/]                 # Optional: configuration files
├── [assets/]                 # Optional: additional resources
└── [other-files]             # Package-specific content
```

### Script Structure

```bash
#!/bin/bash
# [Description matching XY_PACKAGE_DESCRIPTION]

# Standard XY variables (required, in this order)
XY_PACKAGE_NAME="..."
XY_PACKAGE_DESCRIPTION="..."
XY_PACKAGE_VERSION="..."
XY_PREFIX="xy_"
XY_PACKAGE_OUT="../../zip/"

XY_THIN_COLS=100

# Application-specific variables
[APP]_VARIABLE_1="..."
[APP]_VARIABLE_2="..."

# Color palette (required)
COLOR_GREEN="\033[32m"
# ... rest of colors

# Utility functions (print_header, create_separator, etc.)

# Command implementations

# Command routing (package, help, install, uninstall, etc.)

# Default behavior if no command provided
```

## Example Implementation

See `zel.sh` for a complete reference implementation that demonstrates:

- Proper variable organization and naming
- Consistent color usage and styling
- Standard command implementations
- Help text formatting
- Header and separator usage
- Command execution display
- Dry-run support across all commands

## Compliance Checklist

- [ ] All required XY_* variables defined in correct order
- [ ] Standard color palette implemented
- [ ] `help` command with proper styling
- [ ] `package` command using standard template
- [ ] `print_header()` and `create_separator()` functions
- [ ] Command execution formatting with " > " prefix
- [ ] --dry-run support for filesystem operations
- [ ] Consistent error handling and exit codes
- [ ] README.md following documentation format
- [ ] Script name follows [package-name].sh convention

## Notes

- The xypack convention prioritizes consistency over customization
- All styling decisions are intentional and should not be modified
- New xypack scripts should be based on the zel.sh reference implementation
- The template supports both simple and complex applications while maintaining uniformity
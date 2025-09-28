# xyp.sh - XYPack Demo Installer

A demo installer showcasing the xypack standard format for package management scripts.

## Overview

`xyp.sh` is a demonstration of the xypack standard format, designed to download and install the `xy_pack.sh` script as a system-wide binary. This serves as both a functional installer and a reference implementation of xypack conventions.

## Features

- **Standard xypack format**: Follows all xypack conventions for UI, commands, and styling
- **Simple installation**: Downloads and installs xy_pack.sh to `/usr/local/bin/xy_pack`
- **Clean uninstallation**: Removes installed files completely
- **Dry-run support**: Preview operations before execution
- **Package creation**: Generate versioned zip packages

## Installation

```bash
# Install xy_pack system-wide
./xyp.sh install

# Preview installation (dry-run)
./xyp.sh install --dry-run
```

## Available Commands

### Core Commands

#### `install [--dry-run]`
Downloads xy_pack.sh from the GitHub release and installs it to `/usr/local/bin/xy_pack`.

```bash
./xyp.sh install
./xyp.sh install --dry-run
```

#### `uninstall [--dry-run]`
Removes the xy_pack binary from `/usr/local/bin`.

```bash
./xyp.sh uninstall
./xyp.sh uninstall --dry-run
```

#### `package [--dry-run]`
Creates a versioned zip package of the xyp directory, excluding existing .zip files.

```bash
./xyp.sh package
./xyp.sh package --dry-run
```

#### `version [--only]`
Shows package name, description, and version. Use --only to show just the version.

```bash
./xyp.sh version
./xyp.sh version --only
```

#### `help`
Displays usage information and available commands.

```bash
./xyp.sh help
```

## Technical Details

### Package Variables
- **Name**: `xyp`
- **Description**: Demo installer for the xypack standard format
- **Version**: `1.0.0`
- **Download URL**: `https://github.com/ekwoodrich/xypack/releases/download/v1.0.0/xy_pack.sh`
- **Install Path**: `/usr/local/bin/xy_pack`

### XYPack Standard Compliance

This script demonstrates all required xypack features:

- ✅ Standard XY_* variables in correct order
- ✅ Required color palette implementation
- ✅ Consistent UI styling and command patterns
- ✅ Standardized `help`, `package`, `install`, and `uninstall` commands
- ✅ Command execution formatting with " > " prefix
- ✅ --dry-run support for all filesystem operations
- ✅ Proper error handling and exit codes

### File Structure

```
/
├── xyp.sh                   # Main installer script
└── README.md               # This documentation
```

## Requirements

- `bash` (version 4.0 or later)
- `curl` (for downloading)
- `zip` (for package creation)
- Write access to `/usr/local/bin` (for installation)

## Error Handling

The script includes comprehensive error handling:

- Network download failures
- Permission issues during installation
- Missing dependencies
- Invalid command line arguments

All errors are reported with clear, colored output following xypack conventions.

## License

This demo script is part of the xypack project and follows the same licensing terms.
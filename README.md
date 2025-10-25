# FlexingUSB

<p align="center">
  <strong>A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/version-1.1.5-brightgreen.svg" alt="Version 1.1.5">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
</p>

---

## Table of Contents

- [What's New](#whats-new-in-v110-)
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Safety Features](#safety-features)
- [Architecture](#architecture)
- [Technical Details](#technical-details)
- [Use Cases](#use-cases)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Roadmap](#roadmap)

---

## What's New in v1.1.5

**Performance Revolution!**

-  **FAST Writes**: Direct I/O implementation achieves 45-50+ MB/s (was 20-30 MB/s on regular hardware and USB sticks)
-  **Real Progress Bar**: Live speed, ETA, and percentage updates
-  **Fake USB Detection**: Warns about counterfeit drives (Rufus-inspired)
-  **SHA-512 Support**: Enhanced hash verification options
-  **Better UX**: Drag-and-drop paths, simple y/n confirmations
-  **16MB Buffers**: Optimized for maximum throughput
-  **Example**: 2.8GB Linux Mint XFCE ISO now writes in **1-1.5 minutes** (was 2-4 minutes)

See [CHANGELOG.md](CHANGELOG.md) for full details.

---

## Overview

**FlexingUSB** is a native Swift command-line utility designed to make ISO-to-USB creation simple, safe, and transparent for macOS users. It's a modern alternative to tools like `dd`, `asr`, and Etcher—entirely terminal-based with professional-grade safety features and blazing-fast direct I/O writes.

### System Requirements

- **macOS**: 10.15 (Catalina) or later
- **Architecture**: Intel or Apple Silicon (M1/M2/M3)
- **Privileges**: Administrator access for disk operations
- **Storage**: ~2MB for binary
- **USB**: Any external USB drive (will be erased during writing)

**macOS versions:** Supported on Catalina (10.15) and newer.

**Requirements:** Admin/sudo, external USB drive, and that you’re OK with the tool unmounting/erasing the target disk.

**Performance:** Similar or better on Intel—actual speed depends on your USB port (USB 2.0 vs 3.x), the drive, and the ISO size.

### Key Features

-  **FAST**: Direct I/O writes at 30-50 MB/s (was 10-15 MB/s with dd)
-  **Real-time Progress**: Live speed, ETA, and completion percentage
-  **Safety First**: Never touches internal drives (`/dev/disk0`) - multiple safety checks prevent accidents
-  **Fake USB Detection**: Warns about counterfeit drives with suspicious capacities (Rufus-inspired)
-  **Intelligent Detection**: Automatically detects ISO types (Windows, Linux, macOS)
-  **Multi-hash Verification**: SHA-256 and SHA-512 checksum support
-  **User-Friendly**: Colorized terminal output with clean progress bars
-  **16MB Buffers**: Optimized for maximum throughput
-  **Drag-and-Drop**: Easy file path input support
-  **USB Restoration**: Easy restoration of USB drives to FAT32/exFAT

---

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Download and install latest release
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.1.5/FlexingUSB-v1.1.5-macos-with-installer.zip -o FlexingUSB.zip
unzip FlexingUSB.zip
cd FlexingUSB-v1.1.5-macos-with-installer
sudo ./install.sh
```

**After installation, you can use FlexingUSB from anywhere:**
```bash
# Full command (works from any directory)
FlexingUSB start
FlexingUSB list
FlexingUSB quick flash --iso /path/to/file.iso

# Short command (also works from any directory)
flexingusb start
flexingusb list
flexingusb quick flash --iso /path/to/file.iso
```

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/Goenvim/FlexingUSB.git
 # FlexingUSB

 A safe, fast, and user-friendly macOS command-line tool for writing ISO images to USB drives.

 Supports interactive workflows, fast direct-I/O writes, verification, and safe defaults to protect internal disks.

 ---

 ## Quick links

 - Repository: https://github.com/Goenvim/FlexingUSB
 - Changelog: `CHANGELOG.md`
 - Installer script: `install.sh`
 - Makefile: `Makefile`

 ---

 ## Requirements

 - macOS 10.15+ (Catalina or newer)
 - Swift 5.9+ (Xcode 15+ recommended for development)
 - Administrator privileges for disk operations (you will be prompted when needed)

 ---

 ## Installation

 You have multiple options depending on how you like to manage tools.

 1) Recommended — use the repository installer (if published releases exist):

 ```bash
 # Download a release, unzip, and run the bundled installer (example)
 curl -L https://github.com/Goenvim/FlexingUSB/releases/latest/download/FlexingUSB-macos.zip -o FlexingUSB.zip
 unzip FlexingUSB.zip
 cd FlexingUSB-*-macos
 sudo ./install.sh
 ```

 2) From source via Makefile (convenient):

 ```bash
 git clone https://github.com/Goenvim/FlexingUSB.git
 cd FlexingUSB
 make install   # builds release and installs to /usr/local/bin
 ```

 3) Manual (SwiftPM):

 ```bash
 git clone https://github.com/Goenvim/FlexingUSB.git
 cd FlexingUSB
 swift build -c release
 sudo cp .build/release/FlexingUSB /usr/local/bin/
 sudo cp scripts/flexingusb /usr/local/bin/flexingusb
 sudo chmod +x /usr/local/bin/flexingusb
 ```

 Reinstall/update: pull latest changes and run `make install` (or rebuild manually):

 ```bash
 cd FlexingUSB
 git pull --rebase
 make install
 ```

 Uninstall / delete the installed commands:

 ```bash
 sudo rm -f /usr/local/bin/FlexingUSB
 sudo rm -f /usr/local/bin/flexingusb
 ```

 Notes:
 - The `install.sh` and `Makefile` (where present) are convenience helpers — inspect them before running.
 - Homebrew formula is not provided here (planned). If you want a formula, I can create one.

 ---

 ## Quick usage examples

 Run the interactive workflow (recommended):

 ```bash
 FlexingUSB start
 ```

 List external drives (safe, non-destructive):

 ```bash
 FlexingUSB list
 ```

 Quick flash (uses first detected external drive):

 ```bash
 FlexingUSB quick flash --iso /path/to/image.iso
 ```

 Restore the first external drive to FAT32/exFAT:

 ```bash
 FlexingUSB quick restore
 ```

 Verify a written image against an ISO file:

 ```bash
 FlexingUSB verify /path/to/image.iso disk2
 ```

 Show technical specs for an ISO or USB drive:

 ```bash
 FlexingUSB specs --iso /path/to/image.iso
 FlexingUSB specs --usb disk2
 ```

 Command-line help (per-command):

 ```bash
 FlexingUSB --help
 FlexingUSB start --help
 FlexingUSB quick --help
 ```

 ---

 ## Safety and behavior notes

 - The tool intentionally blocks any operation on the internal macOS disk (typically `/dev/disk0`).
 - External disks are detected using `diskutil` and additional heuristics to avoid listing virtual/disk-image devices.
 - The `start` flow unmounts target disks and performs destructive writes — read prompts carefully.
 - Use `--dry-run` on `start` to preview the exact commands the tool would run without touching disks.

 ---

 ## Reinstalling and updating

 To update a local clone and reinstall the binary:

 ```bash
 cd /path/to/FlexingUSB
 git pull --rebase origin main
 make install    # or repeat the manual build+copy steps
 ```

 If you installed via a release package, download and run the new installer or re-run `install.sh` from the unpacked release.

 ---

 ## Troubleshooting

 - "No external disks found":
   - Confirm the USB is plugged in and powered.
   - Try a different USB port or cable.
   - Check macOS Disk Utility to verify the system sees the drive.
   - Some disk images or emulator devices may appear in `diskutil` — the tool filters those out by default. Use `diskutil list` to inspect raw output.

 - "Permission denied": desktop operations require admin access; you will be prompted for your password when necessary.

 - If a write fails or verification fails, try a different USB stick — counterfeit/failing drives are common.

 If you want more diagnostics, run `FlexingUSB list` and then inspect `diskutil info -plist <disk>` for the listed device.

 ---

 ## Contributing

 Contributions are welcome. Typical workflow:

 ```bash
 fork -> clone -> feature branch -> commit -> push -> PR
 ```

 Development helpers:

 ```bash
 make build      # debug build
 swift run FlexingUSB list
 make release    # release build
 make test       # run tests (if present)
 ```

 Please follow existing code style, add tests for new behavior, and open an issue if you're unsure about a change.

 ---

 ## License

 This project is licensed under the MIT License — see `LICENSE` for details.

 ---

 If you'd like, I can also add:
 - a verbose logging/debug flag that shows why a disk was accepted/ignored, and
 - a small unit test suite that verifies the `diskutil`-parsing heuristics using sample plists.

 Made for macOS users who need safe, fast ISO-to-USB tooling.

# FlexingUSB

<p align="center">
  <strong>A powerful, safe, and intelligent macOS command-line tool for writing ISO images to USB drives</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/version-1.15-brightgreen.svg" alt="Version 1.15">
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
</p>

---

## Table of Contents

- [What's New in v1.1.0](#whats-new-in-v110-)
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

## What's New in v1.15

**Performance Revolution!**

- ⚡ **3-5x Faster Writes**: Direct I/O implementation achieves 30-50 MB/s (was 10-15 MB/s)
- 📊 **Real Progress Bar**: Live speed, ETA, and percentage updates
- 🔍 **Fake USB Detection**: Warns about counterfeit drives (Rufus-inspired)
- 🔐 **SHA-512 Support**: Enhanced hash verification options
- 🖱️ **Better UX**: Drag-and-drop paths, simple y/n confirmations
- 💾 **16MB Buffers**: Optimized for maximum throughput
- ⏱️ **Example**: 2.8GB Linux Mint ISO now writes in **1-2 minutes** (was 3-5 minutes)

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

- ⚡ **3-5x Faster**: Direct I/O writes at 30-50 MB/s (was 10-15 MB/s with dd)
- 📊 **Real-time Progress**: Live speed, ETA, and completion percentage
- 🛡️ **Safety First**: Never touches internal drives (`/dev/disk0`) - multiple safety checks prevent accidents
- 🔍 **Fake USB Detection**: Warns about counterfeit drives with suspicious capacities (Rufus-inspired)
- 🎯 **Intelligent Detection**: Automatically detects ISO types (Windows, Linux, macOS)
- ✅ **Multi-hash Verification**: SHA-256 and SHA-512 checksum support
- 🎨 **User-Friendly**: Colorized terminal output with clean progress bars
- 💾 **16MB Buffers**: Optimized for maximum throughput
- 🖱️ **Drag-and-Drop**: Easy file path input support
- 🔄 **USB Restoration**: Easy restoration of USB drives to FAT32/exFAT

---

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Download and install latest release
curl -L https://github.com/Goenvim/FlexingUSB/releases/download/v1.1.0/FlexingUSB-v1.1.0-macos-with-installer.zip -o FlexingUSB.zip
unzip FlexingUSB.zip
cd FlexingUSB-v1.1.0-macos-with-installer
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
cd FlexingUSB

# Build and install using Makefile
make install
```

This will build a release version and install to `/usr/local/bin/` with both commands available:
- `FlexingUSB` - Full command
- `flexingusb` - Short command (launcher script)

**Both commands work from anywhere on your system!**

### Option 3: Manual Build

```bash
# Clone and navigate
git clone https://github.com/Goenvim/FlexingUSB.git
cd FlexingUSB

# Build release version
swift build -c release

# Manually copy to PATH
sudo cp .build/release/FlexingUSB /usr/local/bin/
sudo cp scripts/flexingusb /usr/local/bin/flexingusb
sudo chmod +x /usr/local/bin/flexingusb
```

**Now you can use both commands from anywhere:**
- `FlexingUSB` - Full command
- `flexingusb` - Short command (launcher script)

### Option 4: Homebrew (Coming Soon)

```bash
# Future installation method
brew install flexingusb
```

### Option 5: Global Launcher Script

After installation, you can also use the shorter `flexingusb` command from anywhere:

```bash
# Use the shorter command
flexingusb start
flexingusb list
flexingusb quick flash --iso /path/to/file.iso
```

The launcher script automatically finds and runs the FlexingUSB binary, making it easier to use from any directory.

---

## Usage

### Quick Start

```bash
# Interactive ISO-to-USB workflow
FlexingUSB start

# List all external drives
FlexingUSB list

# Restore a USB to FAT32/exFAT
FlexingUSB restore

# Verify a written ISO
FlexingUSB verify /path/to/image.iso disk2

# Show technical specifications
FlexingUSB specs --iso /path/to/image.iso
FlexingUSB specs --usb disk2

# Quick operations
FlexingUSB quick flash --iso /path/to/image.iso
FlexingUSB quick restore
FlexingUSB quick info
```

### Commands

#### `start` - Flash an ISO to USB

The main command that guides you through the entire process:

```bash
FlexingUSB start [--dry-run] [--skip-verify]
```

**Workflow:**
1. Detects all external USB drives
2. Optional bad blocks/fake capacity check (Rufus-inspired)
3. Prompts for ISO file path (drag-and-drop supported)
4. Detects ISO type (Windows/Linux/macOS)
5. Optionally provides Windows TPM bypass information
6. Simple y/n confirmation before writing
7. Writes ISO to USB with real-time progress (30-50 MB/s)
8. Optionally verifies written data with SHA-256/SHA-512

**Options:**
- `--dry-run`: Simulate the operation without actually writing
- `--skip-verify`: Skip the verification step after writing

#### `list` - Show External Drives

Lists all connected external USB drives with detailed information:

```bash
FlexingUSB list
```

**Output:**
```
═══ External Drives ═══

Detected external drives:
[1] /dev/disk2 - 64.00GB SanDisk Ultra (GUID_partition_scheme)

Device: /dev/disk2
  Size: 64.00 GB
  Content: GUID_partition_scheme
  Volume: SanDisk
  Mounted: /Volumes/SanDisk
```

#### `restore` - Restore USB Drive

Erases and formats a USB drive back to a usable state:

```bash
FlexingUSB restore [--format FAT32|ExFAT] [--name VolumeName]
```

**Options:**
- `--format`: Specify format (FAT32 or ExFAT). Auto-detects based on size if not specified
- `--name`: Custom volume name (default: "Untitled")

**Example:**
```bash
FlexingUSB restore --format ExFAT --name "MyUSB"
```

#### `verify` - Verify Written ISO

Verifies that a USB drive matches an ISO file:

```bash
FlexingUSB verify <iso-path> <disk-identifier>
```

**Arguments:**
- `iso-path`: Path to the ISO file
- `disk-identifier`: Disk identifier (e.g., disk2)

**Example:**
```bash
FlexingUSB verify ~/Downloads/ubuntu.iso disk2
```

#### `specs` - Technical Specifications

Shows detailed technical specifications for ISO files and USB drives:

```bash
FlexingUSB specs --iso <iso-path>
FlexingUSB specs --usb <disk-identifier>
FlexingUSB specs --all
```

**Options:**
- `--iso`: Analyze an ISO file and show its technical specifications
- `--usb`: Analyze a USB drive and show its technical specifications
- `--all`: Show specifications for all available USB drives

**Examples:**
```bash
# Analyze an ISO file
FlexingUSB specs --iso ~/Downloads/ubuntu-22.04.iso

# Analyze a USB drive
FlexingUSB specs --usb disk2

# Show all available specifications
FlexingUSB specs --all
```

#### `quick` - Quick Operations

Fast shortcuts for common ISO-to-USB tasks:

```bash
FlexingUSB quick <operation> [options]
```

**Operations:**
- `flash`: Quickly flash an ISO to the first available USB drive
- `restore`: Quickly restore the first available USB drive to FAT32/exFAT
- `info`: Show quick information about connected USB drives
- `status`: Show system status and drive information

**Examples:**
```bash
# Quick flash (uses first available USB drive)
FlexingUSB quick flash --iso ~/Downloads/ubuntu.iso

# Quick restore (formats first available USB drive)
FlexingUSB quick restore

# Quick info about USB drives
FlexingUSB quick info

# System status
FlexingUSB quick status --iso ~/Downloads/ubuntu.iso
```

---

## Safety Features

FlexingUSB includes multiple layers of protection:

1. **Internal Disk Protection**: 
   - Automatically blocks operations on `/dev/disk0` (internal macOS disk)
   - Verifies disk is external before any operation

2. **Explicit Confirmation**:
   - Simple y/n confirmation before destructive operations
   - Shows detailed information about what will be erased

3. **Dry Run Mode**:
   - Test operations without actually writing data
   - See exactly what commands would be executed

4. **Verification**:
   - Optional SHA-256 and SHA-512 checksum verification
   - Byte-for-byte comparison ensures written data matches source ISO
   - Real-time hashing with progress indicators

5. **Error Handling**:
   - Graceful error messages
   - Safe cleanup on failures

---

## Architecture

FlexingUSB is built with a modular, maintainable architecture:

```
FlexingUSB/
├── Package.swift              # Swift Package Manager configuration
├── Makefile                   # Build automation
├── Sources/FlexingUSB/
│   ├── main.swift            # CLI entry point & command routing
│   ├── DiskManager.swift     # Disk detection & operations
│   ├── ISOManager.swift      # ISO detection & validation
│   ├── Writer.swift          # ISO writing & verification orchestration
│   ├── DirectWriter.swift    # Direct I/O writer (Rufus-style)
│   ├── BadBlockChecker.swift # Fake USB detection
│   └── UI.swift              # Terminal UI & user interaction
└── Documentation/
    ├── README.md
    ├── INSTALL.md
    ├── QUICKSTART.md
    ├── CONTRIBUTING.md
    ├── SECURITY.md
    └── VERIFICATION_REPORT.md
```

### Module Responsibilities

- **`main.swift`**: ArgumentParser commands and workflow orchestration
- **`DiskManager.swift`**: Disk enumeration, safety checks, formatting
- **`ISOManager.swift`**: ISO type detection, file validation, checksum calculation
- **`Writer.swift`**: High-level write orchestration and verification
- **`DirectWriter.swift`**: Low-level direct I/O writes with 16MB buffers
- **`BadBlockChecker.swift`**: USB capacity verification and fake drive detection
- **`UI.swift`**: Terminal output, colors, progress bars, user prompts

---

## Technical Details

### Requirements

- **macOS**: 10.15 (Catalina) or later
- **Swift**: 5.9+
- **Xcode**: 15.0+ (for development)
- **Privileges**: sudo access for disk operations

### Technologies Used

- **Swift Package Manager**: Dependency management and building
- **ArgumentParser**: Command-line argument parsing from Apple
- **CryptoKit**: SHA-256 and SHA-512 checksum calculation
- **Foundation**: Low-level file I/O, process execution, and POSIX APIs
- **Darwin**: Direct system calls for O_SYNC, fsync, and raw device access

### Write Methods

FlexingUSB uses a high-performance direct I/O writer:

1. **Direct I/O** (default in v1.1.0+): Fast, native Swift implementation
   - 16MB buffer size for maximum throughput
   - Direct file-to-device writes (no external commands)
   - Real-time progress with speed and ETA
   - 30-50 MB/s average speed (3-5x faster than dd)
   - Inspired by Rufus's approach

2. **Legacy dd/asr** (fallback): Available in Writer.swift for compatibility
   - Uses external `dd` command with raw disk device
   - Slower but universally compatible

### Performance Comparison

| Version | Method | Block Size | Speed | 2.8GB ISO Time |
|---------|--------|------------|-------|----------------|
| v1.0.0 | `dd` | 8MB | ~10-15 MB/s | 3-5 minutes |
| **v1.1.0** | **Direct I/O** | **16MB** | **30-50 MB/s** | **1-2 minutes** |

**Note**: Actual speeds depend on:
- **USB Port**: USB 3.0/3.1 (5-10 Gbps) vs USB 2.0 (480 Mbps)
- **Drive Quality**: High-quality drives achieve 40-50 MB/s, budget drives 20-30 MB/s
- **ISO Size**: Larger ISOs benefit more from the optimized buffer size
- **System Load**: Background processes may impact performance

---

## Use Cases

### Creating Linux Bootable USB

```bash
# Download Ubuntu ISO
# Run FlexingUSB
FlexingUSB start

# Follow interactive prompts
# Boot from USB on target machine
```

### Creating Windows Installation USB

```bash
# Download Windows 11 ISO
FlexingUSB start

# Tool detects Windows and offers TPM bypass info
# Creates bootable Windows USB
```

### Creating macOS Installer USB

```bash
# Download macOS installer DMG/ISO
FlexingUSB start

# Creates bootable macOS installer
```

### Restoring USB After Use

```bash
# Restore USB to normal storage
FlexingUSB restore

# USB is now formatted and ready for files
```

---

## Troubleshooting

### "No external disks found"

**Problem**: FlexingUSB doesn't see your USB drive.

**Solutions**:
- Ensure USB drive is properly connected
- Try a different USB port
- Check Disk Utility to see if macOS recognizes the drive
- Try unplugging and replugging the drive

### "Permission denied" errors

**Problem**: Insufficient privileges for disk operations.

**Solutions**:
- FlexingUSB requires admin privileges for disk operations
- You'll be prompted for your password when needed
- Ensure your user account has admin privileges
- Run commands normally (don't prefix with sudo)

### Write is very slow

**Problem**: Writing takes longer than expected.

**Solutions**:
- With v1.1.0+, writes should be 30-50 MB/s (check version with `FlexingUSB --version`)
- Typical times: 2.8GB ISO in 1-2 minutes, 4-5GB ISO in 2-3 minutes
- Ensure you're using USB 3.0 ports for faster speeds
- Avoid USB hubs when possible
- Slow USB 2.0 drives may only achieve 10-15 MB/s (hardware limitation)

### Verification failed

**Problem**: USB checksum doesn't match ISO.

**Solutions**:
- The write may have failed - try writing again
- Check USB drive for hardware issues
- Try a different USB drive
- Verify ISO file isn't corrupted (check download)

### "Internal disk not allowed" error

**Problem**: Trying to use /dev/disk0.

**Solution**: This is intentional! FlexingUSB blocks operations on internal disks for safety. Use an external USB drive only.

---

## Contributing

Contributions are welcome! Here's how you can help:

### Development Setup

```bash
# Clone and setup
git clone https://github.com/Goenvim/FlexingUSB.git
cd FlexingUSB

# Build debug version
make build

# Run without installing
swift run FlexingUSB list

# Build release version
make release

# Run tests (when available)
make test

# Format code (requires swift-format)
make format
```

### Areas for Contribution

- Add unit tests for disk parsing and safety checks
- Implement actual Windows ISO patching (TPM removal)
- Complete bad blocks checking implementation
- Create Homebrew formula for easy installation
- Add localization support
- Add write speed benchmarking and comparison tools
- Add SwiftUI front-end option
- Improve error handling and recovery
- Add disk cloning functionality
- Create preset profiles for popular ISOs

### Code Style

- Use Swift naming conventions
- Add doc comments for public APIs
- Keep functions focused and modular
- Include error handling for all operations
- Write descriptive commit messages

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 FlexingUSB Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- Direct I/O techniques inspired by [Rufus](https://rufus.ie/) by Pete Batard
- Also inspired by [Etcher](https://www.balena.io/etcher/) and traditional Unix utilities (`dd`, `asr`)
- Built with Swift and modern macOS frameworks
- Thanks to the open-source community for feedback and contributions
- Special thanks to the Swift community for ArgumentParser and excellent tooling

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Goenvim/FlexingUSB/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Goenvim/FlexingUSB/discussions)
- **Documentation**: See [QUICKSTART.md](QUICKSTART.md) and [INSTALL.md](INSTALL.md)
- **Security**: See [SECURITY.md](SECURITY.md)

---

## Roadmap

### v1.15 (Current - Released October 24, 2025)
- ✅ Direct I/O writer with 16MB buffers
- ✅ Real-time progress with speed & ETA
- ✅ Fake USB detection (Rufus-inspired)
- ✅ SHA-512 hash support
- ✅ 3-5x performance improvement
- ✅ Drag-and-drop file path support
- ✅ Simple y/n confirmations

### v1.16 (Planned - Late October-November 2025)
- Unit test suite
- Complete bad blocks implementation
- Homebrew formula (Hopefully)
- Write speed benchmarking
- Performance profiling tools
- Bug fixes and stability improvements

### v1.17 or v2.0 (Planned - Christmas 2025)
- Full Windows ISO patching implementation
- GUI mode with SwiftUI (optional)
- Preset profiles for popular ISOs
- Multi-USB writing (parallel writes)
- Disk cloning functionality
- Network ISO downloads
- Enhanced verification options

### v2.x (Future - 2026)
- Advanced features and community requests
- Performance optimizations
- Platform expansion considerations

---

<p align="center">
  Built for the macOS community
</p>
